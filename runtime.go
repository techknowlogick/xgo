package main

import "context"

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
