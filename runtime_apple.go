package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// AppleContainersCLIRuntime shells out to Apple's `container` CLI.
type AppleContainersCLIRuntime struct {
	binary string
}

func newAppleContainersCLIRuntime() (*AppleContainersCLIRuntime, error) {
	path, err := exec.LookPath("container")
	if err != nil {
		return nil, fmt.Errorf("Apple Containers CLI not found: %w", err)
	}
	return &AppleContainersCLIRuntime{binary: path}, nil
}

func (a *AppleContainersCLIRuntime) Close() error {
	return nil
}

func (a *AppleContainersCLIRuntime) Ping(ctx context.Context) error {
	out, err := exec.CommandContext(ctx, a.binary, "system", "status").Output()
	if err != nil {
		return fmt.Errorf("apple container service not reachable: %w", err)
	}
	if !strings.Contains(string(out), "is running") {
		return fmt.Errorf("apple container service is not running (start with: container system start)")
	}
	return nil
}

func (a *AppleContainersCLIRuntime) ImageExists(ctx context.Context, ref string) (bool, error) {
	out, err := exec.CommandContext(ctx, a.binary, "image", "list", "-q").Output()
	if err != nil {
		return false, err
	}
	// -q outputs one "name:tag" per line, so we can do an exact line match.
	for _, line := range strings.Split(strings.TrimSpace(string(out)), "\n") {
		if strings.TrimSpace(line) == ref {
			return true, nil
		}
	}
	return false, nil
}

func (a *AppleContainersCLIRuntime) PullImage(ctx context.Context, ref string) error {
	cmd := exec.CommandContext(ctx, a.binary, "image", "pull", ref)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func (a *AppleContainersCLIRuntime) RunContainer(ctx context.Context, opts RunOptions) error {
	args := []string{"run", "--rm"}

	for _, b := range opts.Binds {
		args = append(args, "-v", b)
	}
	for _, e := range opts.Env {
		args = append(args, "-e", e)
	}
	for _, m := range opts.Mounts {
		args = append(args, "--mount", m)
	}

	// Pass through extra args verbatim
	args = append(args, opts.Extra...)

	args = append(args, opts.Image)
	args = append(args, opts.Cmd...)

	cmd := exec.CommandContext(ctx, a.binary, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
