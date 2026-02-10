package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

// ContainerRuntime abstracts container engine operations so that xgo can work
// with different container runtimes via the Docker Engine API.
type ContainerRuntime interface {
	// Ping checks whether the container runtime is reachable.
	Ping(ctx context.Context) error
	// ImageExists reports whether the given image reference is available locally.
	ImageExists(ctx context.Context, ref string) (bool, error)
	// PullImage pulls the given image reference from a registry, streaming
	// progress to stdout.
	PullImage(ctx context.Context, ref string) error
	// RunContainer creates, starts and waits for a container described by opts.
	RunContainer(ctx context.Context, opts RunOptions) error
	// Close releases any resources held by the runtime (e.g. HTTP connections).
	Close() error
}

// RunOptions collects everything needed to start a cross-compilation container.
type RunOptions struct {
	Image    string
	Env      []string
	Binds    []string // host:container[:mode] volume mounts
	Mounts   []string // raw --mount flag values (e.g. type=bind,source=...,target=...)
	Cmd      []string // command + args passed to the container entrypoint
	Extra    []string // extra runtime-specific args (--dockerargs passthrough)
	Platform string   // target platform (e.g. "linux/amd64", "linux/arm/v7")
}

// detectRuntime selects a container runtime based on the user's preference.
// preference is one of "auto", "docker", "podman", "apple".
// It returns the runtime, a human-readable description, or an error.
func detectRuntime(ctx context.Context, preference string) (ContainerRuntime, string, error) {
	probeCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	switch preference {
	case "docker":
		rt, err := tryDocker(probeCtx)
		if err != nil {
			return nil, "", fmt.Errorf("docker runtime unavailable: %w", err)
		}
		return rt, "Docker", nil

	case "podman":
		rt, name, err := tryPodman(probeCtx)
		if err != nil {
			return nil, "", fmt.Errorf("podman runtime unavailable: %w", err)
		}
		return rt, name, nil

	case "apple":
		rt, err := tryApple(probeCtx)
		if err != nil {
			return nil, "", fmt.Errorf("apple containers runtime unavailable: %w", err)
		}
		return rt, "Apple Containers", nil

	case "auto":
		// Try Docker first.
		if rt, err := tryDocker(probeCtx); err == nil {
			return rt, "Docker", nil
		}
		// Try Podman.
		if rt, name, err := tryPodman(probeCtx); err == nil {
			return rt, name, nil
		}
		// Try Apple Containers.
		if rt, err := tryApple(probeCtx); err == nil {
			return rt, "Apple Containers", nil
		}
		return nil, "", fmt.Errorf("no container runtime found (tried Docker, Podman, Apple Containers)")

	default:
		return nil, "", fmt.Errorf("unknown runtime %q (valid values: auto, docker, podman, apple)", preference)
	}
}

// tryDocker attempts to connect to Docker via the default socket.
func tryDocker(ctx context.Context) (ContainerRuntime, error) {
	rt, err := newDockerAPIRuntime("")
	if err != nil {
		return nil, err
	}
	if err := rt.Ping(ctx); err != nil {
		rt.Close()
		return nil, err
	}
	return rt, nil
}

// tryPodman iterates over well-known Podman socket paths and returns
// the first one that responds to a ping.
func tryPodman(ctx context.Context) (ContainerRuntime, string, error) {
	candidates := podmanSocketCandidates()
	for _, sock := range candidates {
		if _, err := os.Stat(sock); err != nil {
			continue
		}
		rt, err := newDockerAPIRuntime("unix://" + sock)
		if err != nil {
			continue
		}
		if err := rt.Ping(ctx); err != nil {
			rt.Close()
			continue
		}
		return rt, fmt.Sprintf("Podman (%s)", sock), nil
	}
	return nil, "", fmt.Errorf("no reachable Podman socket found")
}

// tryApple attempts to use the Apple Containers CLI runtime.
func tryApple(ctx context.Context) (ContainerRuntime, error) {
	rt, err := newAppleContainersCLIRuntime()
	if err != nil {
		return nil, err
	}
	if err := rt.Ping(ctx); err != nil {
		rt.Close()
		return nil, err
	}
	return rt, nil
}

// podmanSocketCandidates returns Podman socket paths to probe.
// It first asks the podman CLI for the machine socket path (works on any
// platform where podman is installed), then falls back to well-known static
// paths for Linux where podman may run natively without a machine VM.
func podmanSocketCandidates() []string {
	var paths []string

	// Ask the podman CLI for the socket -- this handles macOS (all versions)
	// and any platform where podman machine is in use.
	if sock := podmanMachineSocket(); sock != "" {
		paths = append(paths, sock)
	}

	// Some common static paths to check on Linux if podman
	// is running natively without a machine VM.

	// Rootless: $XDG_RUNTIME_DIR/podman/podman.sock
	if xdg := os.Getenv("XDG_RUNTIME_DIR"); xdg != "" {
		paths = append(paths, xdg+"/podman/podman.sock")
	}

	// Rootful
	paths = append(paths, "/run/podman/podman.sock")
	paths = append(paths, "/var/run/podman/podman.sock")

	return paths
}

// podmanMachineSocket asks the podman CLI for the API socket path of the
// default machine. Returns empty string if podman is not installed or the
// command fails (e.g. native Linux without a machine VM).
func podmanMachineSocket() string {
	out, err := exec.Command("podman", "machine", "inspect", "--format", "{{.ConnectionInfo.PodmanSocket.Path}}").Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}
