package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// AppleContainerRuntime talks to the Apple container runtime via the "container" CLI.
type AppleContainerRuntime struct {
}

func newAppleContainerRuntime() (*AppleContainerRuntime, error) {
	return &AppleContainerRuntime{}, nil
}

func (d *AppleContainerRuntime) Close() error {
	return nil
}

func (d *AppleContainerRuntime) Ping(ctx context.Context) error {
	cmd := exec.CommandContext(ctx, "container", "--version")
	// container CLI erroneously printes version information to stderr
	out, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Fprint(os.Stderr, string(out))
		return err
	}
	fmt.Println(strings.TrimSpace(string(out)))
	return nil
}

func (d *AppleContainerRuntime) ImageExists(ctx context.Context, ref string) (bool, error) {
	cmd := exec.CommandContext(ctx, "container", "image", "list", "--quiet")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return false, err
	}
	found := false
	err = cmd.Start()
	if err == nil {
		s := bufio.NewScanner(stdout)
		for s.Scan() {
			if s.Text() == ref {
				found = true
			}
		}
		err = cmd.Wait()
	}
	return found, err
}

func (d *AppleContainerRuntime) PullImage(ctx context.Context, ref string) error {
	cmd := exec.CommandContext(ctx, "container", "image", "pull", ref)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func (d *AppleContainerRuntime) RunContainer(ctx context.Context, opts RunOptions) error {
	args := []string{"run", "--rm"}
	for _, vol := range opts.Binds {
		args = append(args, "-v", vol)
	}
	for _, env := range opts.Env {
		args = append(args, "-e", env)
	}
	for _, arg := range opts.Extra {
		args = append(args, arg)
	}
	args = append(args, opts.Image)
	for _, c := range opts.Cmd {
		args = append(args, c)
	}
	cmd := exec.CommandContext(ctx, "container", args...)
	// cmd.Stdin = os.Stdin // if ForwardSsh
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
