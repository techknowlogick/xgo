package main

import (
	"context"
	"fmt"
	"net/netip"
	"os"
	"strconv"
	"strings"

	"github.com/moby/moby/api/pkg/stdcopy"
	"github.com/moby/moby/api/types/container"
	"github.com/moby/moby/api/types/mount"
	"github.com/moby/moby/client"
	"github.com/moby/moby/client/pkg/jsonmessage"
	ocispec "github.com/opencontainers/image-spec/specs-go/v1"
	"golang.org/x/term"
)

// DockerAPIRuntime talks to Docker (or Podman) via the Docker Engine API socket.
type DockerAPIRuntime struct {
	cli *client.Client
}

func newDockerAPIRuntime(host string) (*DockerAPIRuntime, error) {
	opts := []client.Opt{
		client.FromEnv,
	}
	if host != "" {
		opts = append(opts, client.WithHost(host))
	}
	cli, err := client.New(opts...)
	if err != nil {
		return nil, fmt.Errorf("creating docker client: %w", err)
	}
	return &DockerAPIRuntime{cli: cli}, nil
}

func (d *DockerAPIRuntime) Close() error {
	return d.cli.Close()
}

func (d *DockerAPIRuntime) Ping(ctx context.Context) error {
	_, err := d.cli.ServerVersion(ctx, client.ServerVersionOptions{})
	return err
}

func (d *DockerAPIRuntime) ImageExists(ctx context.Context, ref string) (bool, error) {
	// Use a reference filter so the daemon does the matching.
	result, err := d.cli.ImageList(ctx, client.ImageListOptions{
		Filters: make(client.Filters).Add("reference", ref),
	})
	if err != nil {
		return false, err
	}
	return len(result.Items) > 0, nil
}

func (d *DockerAPIRuntime) PullImage(ctx context.Context, ref string) error {
	resp, err := d.cli.ImagePull(ctx, ref, client.ImagePullOptions{})
	if err != nil {
		return err
	}
	defer resp.Close()

	fd := os.Stdout.Fd()
	isTerminal := term.IsTerminal(int(fd))
	return jsonmessage.DisplayJSONMessagesStream(resp, os.Stdout, fd, isTerminal, nil)
}

func (d *DockerAPIRuntime) RunContainer(ctx context.Context, opts RunOptions) error {
	cfg := &container.Config{
		Image: opts.Image,
		Env:   opts.Env,
	}
	if len(opts.Cmd) > 0 {
		cfg.Cmd = opts.Cmd
	}

	hc := &container.HostConfig{
		Binds: opts.Binds,
	}

	for _, m := range opts.Mounts {
		parsed, err := parseMountString(m)
		if err != nil {
			return fmt.Errorf("invalid mount specification: %w", err)
		}
		hc.Mounts = append(hc.Mounts, parsed)
	}

	parseExtraArgs(opts.Extra, cfg, hc)

	var platform *ocispec.Platform
	if opts.Platform != "" {
		platform = parsePlatform(opts.Platform)
	}

	resp, err := d.cli.ContainerCreate(ctx, client.ContainerCreateOptions{
		Config:     cfg,
		HostConfig: hc,
		Platform:   platform,
	})
	if err != nil {
		return fmt.Errorf("creating container: %w", err)
	}
	containerID := resp.ID

	defer func() {
		// Use Background context so cleanup still works if the parent ctx was cancelled.
		// We can't use `AutoRemove` as some containers may exit too quickly and cleanup before we can fetch logs or the exit code.
		rmCtx := context.Background()
		_, _ = d.cli.ContainerRemove(rmCtx, containerID, client.ContainerRemoveOptions{Force: true})
	}()

	if _, err := d.cli.ContainerStart(ctx, containerID, client.ContainerStartOptions{}); err != nil {
		return fmt.Errorf("starting container: %w", err)
	}

	logs, err := d.cli.ContainerLogs(ctx, containerID, client.ContainerLogsOptions{
		ShowStdout: true,
		ShowStderr: true,
		Follow:     true,
	})
	if err != nil {
		return fmt.Errorf("reading container logs: %w", err)
	}
	defer logs.Close()

	// ContainerLogs returns a multiplexed stream (stdout/stderr headers)
	// when the container was created without TTY.
	_, _ = stdcopy.StdCopy(os.Stdout, os.Stderr, logs)

	// Wait for exit after logs stream closes so we reliably get the exit code.
	// ContainerWait called before start can return StatusCode=0 on Docker 28.x
	// for fast-exiting containers.
	wait := d.cli.ContainerWait(ctx, containerID, client.ContainerWaitOptions{
		Condition: container.WaitConditionNotRunning,
	})
	select {
	case result := <-wait.Result:
		if result.Error != nil {
			return fmt.Errorf("container error: %s", result.Error.Message)
		}
		if result.StatusCode != 0 {
			return fmt.Errorf("container exited with status %d", result.StatusCode)
		}
		return nil
	case err := <-wait.Error:
		return fmt.Errorf("waiting for container: %w", err)
	}
}

// parseMountString parses a Docker --mount flag value like
// "type=bind,source=/a,target=/b" into a mount.Mount.
func parseMountString(s string) (mount.Mount, error) {
	m := mount.Mount{}
	for _, part := range strings.Split(s, ",") {
		kv := strings.SplitN(part, "=", 2)
		if len(kv) != 2 {
			continue
		}
		switch kv[0] {
		case "type":
			m.Type = mount.Type(kv[1])
		case "source", "src":
			m.Source = kv[1]
		case "target", "dst", "destination":
			m.Target = kv[1]
		case "readonly", "ro":
			m.ReadOnly = kv[1] == "true" || kv[1] == "1"
		}
	}
	if m.Type == "" || m.Source == "" || m.Target == "" {
		return m, fmt.Errorf("incomplete mount specification: %s", s)
	}
	return m, nil
}

// parseExtraArgs maps a subset of well-known docker run flags into Config and
// HostConfig fields. Unrecognised flags are logged as warnings.
func parseExtraArgs(args []string, cfg *container.Config, hc *container.HostConfig) {
	for i := 0; i < len(args); i++ {
		arg := args[i]
		key := arg
		if idx := strings.IndexByte(key, '='); idx >= 0 {
			key = key[:idx]
		}
		switch {
		case key == "--privileged":
			hc.Privileged = true

		case key == "--network":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.NetworkMode = container.NetworkMode(val)
			}
		case key == "--cap-add":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.CapAdd = append(hc.CapAdd, val)
			}
		case key == "--cap-drop":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.CapDrop = append(hc.CapDrop, val)
			}
		case key == "--pid":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.PidMode = container.PidMode(val)
			}
		case key == "--security-opt":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.SecurityOpt = append(hc.SecurityOpt, val)
			}

		case key == "--memory":
			val := flagValue(arg, args, &i)
			if val != "" {
				if n, err := parseMemoryString(val); err == nil {
					hc.Memory = n
				}
			}
		case key == "--memory-swap":
			val := flagValue(arg, args, &i)
			if val != "" {
				if n, err := parseMemoryString(val); err == nil {
					hc.MemorySwap = n
				}
			}
		case key == "-m":
			val := flagValue(arg, args, &i)
			if val != "" {
				if n, err := parseMemoryString(val); err == nil {
					hc.Memory = n
				}
			}
		case key == "--cpus":
			val := flagValue(arg, args, &i)
			if val != "" {
				if f, err := strconv.ParseFloat(val, 64); err == nil {
					hc.NanoCPUs = int64(f * 1e9)
				}
			}
		case key == "--device":
			val := flagValue(arg, args, &i)
			if val != "" {
				parts := strings.SplitN(val, ":", 3)
				dm := container.DeviceMapping{PathOnHost: parts[0]}
				if len(parts) > 1 {
					dm.PathInContainer = parts[1]
				} else {
					dm.PathInContainer = parts[0]
				}
				if len(parts) > 2 {
					dm.CgroupPermissions = parts[2]
				} else {
					dm.CgroupPermissions = "rwm"
				}
				hc.Devices = append(hc.Devices, dm)
			}
		case key == "--tmpfs":
			val := flagValue(arg, args, &i)
			if val != "" {
				parts := strings.SplitN(val, ":", 2)
				target := parts[0]
				opts := ""
				if len(parts) > 1 {
					opts = parts[1]
				}
				if hc.Tmpfs == nil {
					hc.Tmpfs = make(map[string]string)
				}
				hc.Tmpfs[target] = opts
			}

		case key == "--user" || key == "-u":
			val := flagValue(arg, args, &i)
			if val != "" {
				cfg.User = val
			}
		case key == "--entrypoint":
			val := flagValue(arg, args, &i)
			if val != "" {
				cfg.Entrypoint = []string{val}
			}
		case key == "--shm-size":
			val := flagValue(arg, args, &i)
			if val != "" {
				if n, err := parseMemoryString(val); err == nil {
					hc.ShmSize = n
				}
			}

		case key == "--hostname" || key == "-h":
			val := flagValue(arg, args, &i)
			if val != "" {
				cfg.Hostname = val
			}

		case key == "--dns":
			val := flagValue(arg, args, &i)
			if val != "" {
				if addr, err := netip.ParseAddr(val); err == nil {
					hc.DNS = append(hc.DNS, addr)
				}
			}

		case key == "--add-host":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.ExtraHosts = append(hc.ExtraHosts, val)
			}

		case key == "--ipc":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.IpcMode = container.IpcMode(val)
			}

		case key == "--init":
			init := true
			hc.Init = &init

		case key == "-v" || key == "--volume":
			val := flagValue(arg, args, &i)
			if val != "" {
				hc.Binds = append(hc.Binds, val)
			}

		case key == "-e" || key == "--env":
			val := flagValue(arg, args, &i)
			if val != "" {
				cfg.Env = append(cfg.Env, val)
			}

		case key == "--mount":
			val := flagValue(arg, args, &i)
			if val != "" {
				m, err := parseMountString(val)
				if err == nil {
					hc.Mounts = append(hc.Mounts, m)
				}
			}

		default:
			fmt.Fprintf(os.Stderr, "Warning: unrecognised docker arg %q ignored in API mode\n", arg)
		}
	}
}

// parsePlatform converts a string like "linux/amd64" or "linux/arm/v7"
// into an OCI platform spec.
func parsePlatform(s string) *ocispec.Platform {
	parts := strings.SplitN(s, "/", 3)
	p := &ocispec.Platform{}
	if len(parts) >= 1 {
		p.OS = parts[0]
	}
	if len(parts) >= 2 {
		p.Architecture = parts[1]
	}
	if len(parts) >= 3 {
		p.Variant = parts[2]
	}
	return p
}

// parseMemoryString parses a Docker-style memory string like "512m", "1g", "1024"
// into bytes.
func parseMemoryString(s string) (int64, error) {
	s = strings.TrimSpace(strings.ToLower(s))
	if s == "" {
		return 0, fmt.Errorf("empty memory string")
	}

	multiplier := int64(1)
	switch {
	case strings.HasSuffix(s, "k"):
		multiplier = 1024
		s = s[:len(s)-1]
	case strings.HasSuffix(s, "m"):
		multiplier = 1024 * 1024
		s = s[:len(s)-1]
	case strings.HasSuffix(s, "g"):
		multiplier = 1024 * 1024 * 1024
		s = s[:len(s)-1]
	}

	n, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return 0, err
	}
	return n * multiplier, nil
}

// flagValue extracts the value from either "--flag=value" or "--flag value" forms.
func flagValue(arg string, args []string, i *int) string {
	if idx := strings.IndexByte(arg, '='); idx >= 0 {
		return arg[idx+1:]
	}
	if *i+1 < len(args) {
		*i++
		return args[*i]
	}
	return ""
}
