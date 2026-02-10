// Go CGO cross compiler
// Copyright (c) 2014 Péter Szilágyi. All rights reserved.
// Copyright (c) 2019 techknowlogick. All rights reserved.
//
// Released under the MIT license.

// Wrapper around the GCO cross compiler docker container.
package main // import "src.techknowlogick.com/xgo"

import (
	"bytes"
	"context"
	"flag"
	"fmt"
	"go/build"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"os/user"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

// Path where to cache external dependencies
var depsCache string

func init() {
	// Initialize the external dependency cache path to a few possible locations
	if home := os.Getenv("HOME"); home != "" {
		depsCache = filepath.Join(home, ".xgo-cache")
		return
	}
	if usr, err := user.Current(); usr != nil && err == nil && usr.HomeDir != "" {
		depsCache = filepath.Join(usr.HomeDir, ".xgo-cache")
		return
	}
	depsCache = filepath.Join(os.TempDir(), "xgo-cache")
}

// Cross compilation docker containers
var (
	dockerDist = "ghcr.io/techknowlogick/xgo:"
)

// Command line arguments to fine tune the compilation
var (
	goVersion   = flag.String("go", "latest", "Go release to use for cross compilation")
	srcPackage  = flag.String("pkg", "", "Sub-package to build if not root import")
	srcRemote   = flag.String("remote", "", "Version control remote repository to build")
	srcBranch   = flag.String("branch", "", "Version control branch to build")
	outPrefix   = flag.String("out", "", "Prefix to use for output naming (empty = package name)")
	outFolder   = flag.String("dest", "", "Destination folder to put binaries in (empty = current)")
	crossDeps   = flag.String("deps", "", "CGO dependencies (configure/make based archives)")
	crossArgs   = flag.String("depsargs", "", "CGO dependency configure arguments")
	targets     = flag.String("targets", "*/*", "Comma separated targets to build for")
	dockerImage = flag.String("image", "", "Use custom docker image instead of official distribution")
	dockerEnv   = flag.String("env", "", "Comma separated custom environments added to docker run -e")
	dockerArgs  = flag.String("dockerargs", "", "Comma separated arguments added to docker run")
	volumes     = flag.String("volumes", "", "Comma separated list of volume mounts in format source:target[:mode]")
	hooksDir    = flag.String("hooksdir", "", "Directory with user hook scripts (setup.sh, build.sh)")
	runtimeName = flag.String("container", "docker", "Select the container runtime (docker, apple)")
	forwardSsh  = flag.Bool("ssh", false, "Enable ssh agent forwarding")
)

// ConfigFlags is a simple set of flags to define the environment and dependencies.
type ConfigFlags struct {
	Repository   string   // Root import path to build
	Package      string   // Sub-package to build if not root import
	Prefix       string   // Prefix to use for output naming
	Remote       string   // Version control remote repository to build
	Branch       string   // Version control branch to build
	Dependencies string   // CGO dependencies (configure/make based archives)
	Arguments    string   // CGO dependency configure arguments
	Targets      []string // Targets to build for
	DockerEnv    []string // Custom environments added to docker run -e
	DockerArgs   []string // Custom options added to docker run
	Volumes      []string // Volume mounts for docker run -v
	ForwardSsh   bool     // Enable ssh agent forwarding
}

// Command line arguments to pass to go build
var (
	buildVerbose  = flag.Bool("v", false, "Print the names of packages as they are compiled")
	buildSteps    = flag.Bool("x", false, "Print the command as executing the builds")
	buildRace     = flag.Bool("race", false, "Enable data race detection (supported only on amd64)")
	buildTags     = flag.String("tags", "", "List of build tags to consider satisfied during the build")
	buildLdFlags  = flag.String("ldflags", "", "Arguments to pass on each go tool link invocation")
	buildGcFlags  = flag.String("gcflags", "", "Arguments to pass on each go tool compile invocation")
	buildMode     = flag.String("buildmode", "default", "Indicates which kind of object file to build")
	buildTrimpath = flag.Bool("trimpath", false, "Indicates if trimpath should be applied to build")
	buildBuildVCS = flag.Bool("buildvcs", true, "Whether to stamp binaries with version control information")
	obfuscate     = flag.Bool("obfuscate", false, "Obfuscate build using garble")
	garbleFlags   = flag.String("garbleflags", "", "Arguments to pass to garble (e.g. -seed=random)")
)

// BuildFlags is a simple collection of flags to fine tune a build.
type BuildFlags struct {
	Verbose     bool   // Print the names of packages as they are compiled
	Steps       bool   // Print the command as executing the builds
	Race        bool   // Enable data race detection (supported only on amd64)
	Tags        string // List of build tags to consider satisfied during the build
	LdFlags     string // Arguments to pass on each go tool link invocation
	GcFlags     string // Arguments to pass on each go tool compile invocation
	Mode        string // Indicates which kind of object file to build
	Trimpath    bool   // Indicates if trimpath should be applied to build
	BuildVCS    bool   // Whether to stamp binaries with version control information
	Obfuscate   bool   // Obfuscate build using garble
	GarbleFlags string // Arguments to pass to garble
}

func main() {
	// Retrieve the CLI flags and the execution environment
	flag.Parse()

	// Cancel all container operations on Ctrl-C (SIGINT/SIGTERM).
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	xgoInXgo := os.Getenv("XGO_IN_XGO") == "1"
	if xgoInXgo {
		depsCache = "/deps-cache"
	}
	// Only use docker images if we're not already inside out own image
	image := ""

	var rt ContainerRuntime
	if !xgoInXgo {
		// Initialise the Docker container runtime
		var err error
		switch *runtimeName {
		case "docker":
			rt, err = newDockerAPIRuntime("")
		case "apple":
			rt, err = newAppleContainerRuntime()
		default:
			log.Fatalf("unknown container runtime: %q", *runtimeName)
		}
		if err != nil {
			log.Fatalf("Failed to initialize %s container runtime: %v.", *runtimeName, err)
		}

		defer rt.Close()
		// Ensure the runtime is reachable
		fmt.Println("Checking container runtime...")
		if err := rt.Ping(ctx); err != nil {
			log.Fatalf("Failed to reach container runtime: %v.", err)
		}
		fmt.Println()
		// Validate the command line arguments
		if len(flag.Args()) != 1 {
			log.Fatalf("Usage: %s [options] <go import path>", os.Args[0])
		}
		// Select the image to use, either official or custom
		image = dockerDist + *goVersion
		if *dockerImage != "" {
			image = *dockerImage
		}
		// Check that all required images are available
		fmt.Printf("Checking for required docker image %s... ", image)
		found, err := rt.ImageExists(ctx, image)
		switch {
		case err != nil:
			log.Fatalf("Failed to check docker image availability: %v.", err)
		case !found:
			fmt.Println("not found!")
			fmt.Printf("Pulling %s from registry...\n", image)
			if err := rt.PullImage(ctx, image); err != nil {
				log.Fatalf("Failed to pull docker image from the registry: %v.", err)
			}
		default:
			fmt.Println("found.")
		}
	}
	// Cache all external dependencies to prevent always hitting the internet
	if *crossDeps != "" {
		if err := os.MkdirAll(depsCache, 0o750); err != nil {
			log.Fatalf("Failed to create dependency cache: %v.", err)
		}
		// Download all missing dependencies
		for _, dep := range strings.Split(*crossDeps, " ") {
			if url := strings.TrimSpace(dep); len(url) > 0 {
				path := filepath.Join(depsCache, filepath.Base(url))

				if _, err := os.Stat(path); err != nil {
					fmt.Printf("Downloading new dependency: %s...\n", url)

					out, err := os.Create(path)
					if err != nil {
						log.Fatalf("Failed to create dependency file: %v.", err)
					}
					res, err := http.Get(url)
					if err != nil {
						log.Fatalf("Failed to retrieve dependency: %v.", err)
					}
					defer res.Body.Close()

					if _, err := io.Copy(out, res.Body); err != nil {
						log.Fatalf("Failed to download dependency: %v", err)
					}
					out.Close()

					fmt.Printf("New dependency cached: %s.\n", path)
				} else {
					fmt.Printf("Dependency already cached: %s.\n", path)
				}
			}
		}
	}
	// Assemble the cross compilation environment and build options
	config := &ConfigFlags{
		Repository:   flag.Args()[0],
		Package:      *srcPackage,
		Remote:       *srcRemote,
		Branch:       *srcBranch,
		Prefix:       *outPrefix,
		Dependencies: *crossDeps,
		Arguments:    *crossArgs,
		Targets:      strings.Split(*targets, ","),
		DockerEnv:    strings.Split(*dockerEnv, ","),
		DockerArgs:   strings.Split(*dockerArgs, ","),
		Volumes:      strings.Split(*volumes, ","),
		ForwardSsh:   *forwardSsh,
	}
	flags := &BuildFlags{
		Verbose:     *buildVerbose,
		Steps:       *buildSteps,
		Race:        *buildRace,
		Tags:        *buildTags,
		LdFlags:     *buildLdFlags,
		GcFlags:     *buildGcFlags,
		Mode:        *buildMode,
		Trimpath:    *buildTrimpath,
		BuildVCS:    *buildBuildVCS,
		Obfuscate:   *obfuscate,
		GarbleFlags: *garbleFlags,
	}
	folder, err := os.Getwd()
	if err != nil {
		log.Fatalf("Failed to retrieve the working directory: %v.", err)
	}
	if *outFolder != "" {
		folder, err = filepath.Abs(*outFolder)
		if err != nil {
			log.Fatalf("Failed to resolve destination path (%s): %v.", *outFolder, err)
		}
	}
	if *hooksDir != "" {
		dir, err := filepath.Abs(*hooksDir)
		if err != nil {
			log.Fatalf("Failed to resolve hooksdir path (%s): %v.", *hooksDir, err)
		}
		if i, err := os.Stat(dir); err != nil {
			log.Fatalf("Failed to resolve hooksdir path (%s): %v.", *hooksDir, err)
		} else if !i.IsDir() {
			log.Fatalf("Given hooksdir (%s) is not a directory.", *hooksDir)
		}
		config.DockerArgs = append(config.DockerArgs, "--mount", fmt.Sprintf(`type=bind,source=%s,target=/hooksdir`, dir))
	}
	// Execute the cross compilation, either in a container or the current system
	if !xgoInXgo {
		err = compile(ctx, rt, image, config, flags, folder)
	} else {
		err = compileContained(config, flags, folder)
	}
	if err != nil {
		log.Fatalf("Failed to cross compile package: %v.", err)
	}
}

// compile cross builds a requested package according to the given build specs
// using a specific docker cross compilation image.
func compile(ctx context.Context, rt ContainerRuntime, image string, config *ConfigFlags, flags *BuildFlags, folder string) error {
	// We need to consider our module-aware status
	go111module := os.Getenv("GO111MODULE")
	localBuild := strings.HasPrefix(config.Repository, string(filepath.Separator)) || strings.HasPrefix(config.Repository, ".")
	if !localBuild {
		fmt.Printf("Cross compiling non-local repository: %s...\n", config.Repository)
		opts := toRunOptions(image, config, flags, folder)
		if go111module == "" {
			// We're going to be kind to our users and let an empty GO111MODULE fall back to auto mode.
			go111module = "auto"
		}
		opts.Env = append(opts.Env, "GO111MODULE="+go111module)
		opts.Cmd = []string{config.Repository}

		return rt.RunContainer(ctx, opts)
	}

	usesModules := true
	if go111module == "off" {
		usesModules = false
	} else if go111module != "on" {
		usesModules = false
		// we need to look at the current config and determine if we should use modules...
		if _, err := os.Stat(config.Repository + "/go.mod"); err == nil {
			usesModules = true
		}
		if !usesModules {
			// Walk the parents looking for a go.mod file!
			absRepository, err := filepath.Abs(config.Repository)
			if err == nil {
				goModDir := absRepository
				// now walk backwards as per go behaviour
				for {
					if stat, err := os.Stat(filepath.Join(goModDir, "go.mod")); err == nil {
						usesModules = !stat.IsDir()
						break
					}
					parent := filepath.Dir(goModDir)
					if len(parent) >= len(goModDir) {
						break
					}
					goModDir = parent
				}

				if usesModules {
					sourcePath, _ := filepath.Rel(goModDir, absRepository)
					if config.Package == "" {
						config.Package = sourcePath
					} else {
						config.Package = filepath.Join(sourcePath, config.Package)
					}

					config.Repository = goModDir
				}
			}
		}
		if !usesModules {
			// Resolve the repository import path from the file path
			config.Repository = resolveImportPath(config.Repository)

			if _, err := os.Stat(config.Repository + "/go.mod"); err == nil {
				usesModules = true
			}
		}
	}

	// Assemble and run the cross compilation command
	fmt.Printf("Cross compiling local repository: %s : %s...\n", config.Repository, config.Package)
	opts := toRunOptions(image, config, flags, folder)

	if usesModules {
		opts.Env = append(opts.Env, "GO111MODULE=on")
		gopathEnv := getGOPATH()
		if gopathEnv != "" {
			opts.Binds = append(opts.Binds, gopathEnv+":/go")
		}
		// FIXME: consider GOMODCACHE?

		fmt.Printf("Enabled Go module support\n")

		// Map this repository to the /source folder
		absRepository, err := filepath.Abs(config.Repository)
		if err != nil {
			log.Fatalf("Failed to locate requested module repository: %v.", err)
		}

		opts.Binds = append(opts.Binds, absRepository+":/source")

		// Check if there is a vendor folder, and if so, use it
		vendorPath := absRepository + "/vendor"
		vendorfolder, err := os.Stat(vendorPath)
		if !os.IsNotExist(err) && vendorfolder.Mode().IsDir() {
			opts.Env = append(opts.Env, "FLAG_MOD=vendor")
			fmt.Printf("Using vendored Go module dependencies\n")
		}
	} else {
		// If we're performing a local build and we're not using modules we need to map the gopath over
		opts.Env = append(opts.Env, "GO111MODULE=off")
		binds, env := goPathExports()
		opts.Binds = append(opts.Binds, binds...)
		opts.Env = append(opts.Env, env...)
	}

	opts.Cmd = []string{config.Repository}

	return rt.RunContainer(ctx, opts)
}

// toRunOptions builds a RunOptions from config, flags and folder.
func toRunOptions(image string, config *ConfigFlags, flags *BuildFlags, folder string) RunOptions {
	// Alter paths so they work for Windows
	// Does not affect Linux paths
	re := regexp.MustCompile("([A-Z]):")
	folderW := filepath.ToSlash(re.ReplaceAllString(folder, "/$1"))
	depsCacheW := filepath.ToSlash(re.ReplaceAllString(depsCache, "/$1"))
	gocache := filepath.Join(depsCache, "gocache")
	if err := os.MkdirAll(gocache, 0o750); err != nil { // 0750 = rwxr-x---
		log.Fatalf("Failed to create gocache dir: %v.", err)
	}
	gocacheW := filepath.ToSlash(re.ReplaceAllString(gocache, "/$1"))

	opts := RunOptions{
		Image: image,
		Binds: []string{
			folderW + ":/build",
			depsCacheW + ":/deps-cache:ro",
			gocacheW + ":/gocache:rw",
		},
		Env: []string{
			"REPO_REMOTE=" + config.Remote,
			"REPO_BRANCH=" + config.Branch,
			"PACK=" + config.Package,
			"DEPS=" + config.Dependencies,
			"ARGS=" + config.Arguments,
			"OUT=" + config.Prefix,
			fmt.Sprintf("FLAG_V=%v", flags.Verbose),
			fmt.Sprintf("FLAG_X=%v", flags.Steps),
			fmt.Sprintf("FLAG_RACE=%v", flags.Race),
			fmt.Sprintf("FLAG_TAGS=%s", flags.Tags),
			fmt.Sprintf("FLAG_LDFLAGS=%s", flags.LdFlags),
			fmt.Sprintf("FLAG_GCFLAGS=%s", flags.GcFlags),
			fmt.Sprintf("FLAG_BUILDMODE=%s", flags.Mode),
			fmt.Sprintf("FLAG_TRIMPATH=%v", flags.Trimpath),
			fmt.Sprintf("FLAG_BUILDVCS=%v", flags.BuildVCS),
			fmt.Sprintf("FLAG_OBFUSCATE=%v", flags.Obfuscate),
			fmt.Sprintf("GARBLE_FLAGS=%s", flags.GarbleFlags),
			"TARGETS=" + strings.Replace(strings.Join(config.Targets, " "), "*", ".", -1),
			fmt.Sprintf("GOPROXY=%s", os.Getenv("GOPROXY")),
			fmt.Sprintf("GOPRIVATE=%s", os.Getenv("GOPRIVATE")),
			fmt.Sprintf("GOEXPERIMENT=%s", os.Getenv("GOEXPERIMENT")),
		},
	}

	// Set custom environment variables
	for _, s := range config.DockerEnv {
		if s != "" {
			opts.Env = append(opts.Env, s)
		}
	}

	// Set custom volume mounts
	for _, s := range config.Volumes {
		if s != "" {
			opts.Binds = append(opts.Binds, s)
		}
	}

	// Separate --mount and --platform from other docker args so they can be
	// handled as typed fields rather than raw CLI passthrough.
	var extra []string
	for i := 0; i < len(config.DockerArgs); i++ {
		s := config.DockerArgs[i]
		if s == "" {
			continue
		}
		switch {
		case s == "--mount" && i+1 < len(config.DockerArgs):
			opts.Mounts = append(opts.Mounts, config.DockerArgs[i+1])
			i++
		case s == "--platform" && i+1 < len(config.DockerArgs):
			opts.Platform = config.DockerArgs[i+1]
			i++
		case strings.HasPrefix(s, "--platform="):
			opts.Platform = s[len("--platform="):]
		default:
			extra = append(extra, s)
		}
	}
	opts.Extra = extra

	if config.ForwardSsh && os.Getenv("SSH_AUTH_SOCK") != "" {
		// Mount ssh agent socket
		opts.Binds = append(opts.Binds, fmt.Sprintf("%[1]s:%[1]s", os.Getenv("SSH_AUTH_SOCK")))
		// Set ssh agent socket environment variable
		opts.Env = append(opts.Env, fmt.Sprintf("SSH_AUTH_SOCK=%s", os.Getenv("SSH_AUTH_SOCK")))
	}
	return opts
}

// goPathExports returns volume binds and environment variables needed to share
// the host GOPATH with the container (for non-module builds).
func goPathExports() (binds []string, env []string) {
	var locals, mounts, paths []string
	log.Printf("Preparing GOPATH src to be shared with xgo")

	// First determine the GOPATH
	gopathEnv := getGOPATH()
	if gopathEnv == "" {
		log.Printf("No $GOPATH is set or forwarded to xgo")
		return
	}

	// Iterate over all the local libs and export the mount points
	for _, gopath := range strings.Split(gopathEnv, string(os.PathListSeparator)) {
		// Since docker sandboxes volumes, resolve any symlinks manually
		sources := filepath.Join(gopath, "src")
		absSources, err := filepath.Abs(sources)
		if err != nil {
			log.Fatalf("Unable to generate absolute path for source directory %s. %v", sources, err)
		}
		absSources = filepath.ToSlash(filepath.Join(absSources, string(filepath.Separator)))
		_ = filepath.Walk(sources, func(path string, info os.FileInfo, err error) error {
			// Skip any folders that errored out
			if err != nil {
				log.Printf("Failed to access GOPATH element %s: %v", path, err)
				return nil
			}
			// Skip anything that's not a symlink
			if info.Mode()&os.ModeSymlink == 0 {
				return nil
			}
			// Resolve the symlink and skip if it's not a folder
			target, err := filepath.EvalSymlinks(path)
			if err != nil {
				return nil
			}
			if info, err = os.Stat(target); err != nil || !info.IsDir() {
				return nil
			}
			// Skip if the symlink points within GOPATH
			absTarget, err := filepath.Abs(target)
			if err == nil {
				absTarget = filepath.ToSlash(filepath.Join(absTarget, string(filepath.Separator)))
				if strings.HasPrefix(absTarget, absSources) {
					return nil
				}
			}

			// Folder needs explicit mounting due to docker symlink security
			locals = append(locals, target)
			mounts = append(mounts, filepath.Join("/ext-go", strconv.Itoa(len(locals)), "src", strings.TrimPrefix(path, sources)))
			paths = append(paths, filepath.Join("/ext-go", strconv.Itoa(len(locals))))
			return nil
		})
		// Export the main mount point for this GOPATH entry
		locals = append(locals, sources)
		mounts = append(mounts, filepath.Join("/ext-go", strconv.Itoa(len(locals)), "src"))
		paths = append(paths, filepath.Join("/ext-go", strconv.Itoa(len(locals))))
	}

	for i := 0; i < len(locals); i++ {
		binds = append(binds, fmt.Sprintf("%s:%s:ro", locals[i], mounts[i]))
	}
	env = append(env, "EXT_GOPATH="+strings.Join(paths, ":"))
	return binds, env
}

func getGOPATH() string {
	// First determine the GOPATH
	gopathEnv := os.Getenv("GOPATH")
	if gopathEnv == "" {
		log.Printf("No $GOPATH is set - defaulting to %s", build.Default.GOPATH)
		gopathEnv = build.Default.GOPATH
	}

	if gopathEnv == "" {
		log.Printf("No $GOPATH is set or forwarded to xgo")
	}
	return gopathEnv
}

// compileContained cross builds a requested package according to the given build
// specs using the current system opposed to running in a container. This is meant
// to be used for cross compilation already from within an xgo image, allowing the
// inheritance and bundling of the root xgo images.
func compileContained(config *ConfigFlags, flags *BuildFlags, folder string) error {
	// If a local build was requested, resolve the import path
	local := strings.HasPrefix(config.Repository, string(filepath.Separator)) || strings.HasPrefix(config.Repository, ".")
	if local {
		config.Repository = resolveImportPath(config.Repository)
	}
	// Fine tune the original environment variables with those required by the build script
	env := []string{
		"REPO_REMOTE=" + config.Remote,
		"REPO_BRANCH=" + config.Branch,
		"PACK=" + config.Package,
		"DEPS=" + config.Dependencies,
		"ARGS=" + config.Arguments,
		"OUT=" + config.Prefix,
		fmt.Sprintf("FLAG_V=%v", flags.Verbose),
		fmt.Sprintf("FLAG_X=%v", flags.Steps),
		fmt.Sprintf("FLAG_RACE=%v", flags.Race),
		fmt.Sprintf("FLAG_TAGS=%s", flags.Tags),
		fmt.Sprintf("FLAG_LDFLAGS=%s", flags.LdFlags),
		fmt.Sprintf("FLAG_GCFLAGS=%s", flags.GcFlags),
		fmt.Sprintf("FLAG_BUILDMODE=%s", flags.Mode),
		fmt.Sprintf("FLAG_TRIMPATH=%v", flags.Trimpath),
		fmt.Sprintf("FLAG_BUILDVCS=%v", flags.BuildVCS),
		fmt.Sprintf("FLAG_OBFUSCATE=%v", flags.Obfuscate),
		fmt.Sprintf("GARBLE_FLAGS=%s", flags.GarbleFlags),
		"TARGETS=" + strings.Replace(strings.Join(config.Targets, " "), "*", ".", -1),
	}
	if local {
		env = append(env, "EXT_GOPATH=/non-existent-path-to-signal-local-build")
	}
	// Assemble and run the local cross compilation command
	fmt.Printf("Cross compiling %s...\n", config.Repository)

	cmd := exec.Command("/build.sh", config.Repository)
	cmd.Env = append(os.Environ(), env...)

	return run(cmd)
}

// resolveImportPath converts a package given by a relative path to a Go import
// path using the local GOPATH environment.
func resolveImportPath(path string) string {
	abs, err := filepath.Abs(path)
	if err != nil {
		log.Fatalf("Failed to locate requested package: %v.", err)
	}
	stat, err := os.Stat(abs)
	if err != nil || !stat.IsDir() {
		log.Fatalf("Requested path invalid.")
	}
	pack, err := build.ImportDir(abs, build.FindOnly)
	if err != nil {
		log.Fatalf("Failed to resolve import path: %v.", err)
	}
	return pack.ImportPath
}

// compare output of docker/container images and image name
func compareOutAndImage(out []byte, image string) (bool, error) {
	if strings.Contains(image, ":") {
		res := strings.SplitN(image, ":", 2)
		r, t := res[0], res[1]
		match, _ := regexp.Match(fmt.Sprintf(`%s\s+%s`, r, t), out)
		return match, nil
	}
	return bytes.Contains(out, []byte(image)), nil
}

// Executes a command synchronously, redirecting its output to stdout.
func run(cmd *exec.Cmd) error {
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
