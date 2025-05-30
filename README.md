# xgo - Go CGO Cross Compiler

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Docker-based Go cross compiler that enables easy compilation of Go projects with CGO dependencies across multiple platforms and architectures.

## Table of Contents

- [xgo - Go CGO Cross Compiler](#xgo---go-cgo-cross-compiler)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [Installation](#installation)
    - [Docker Image](#docker-image)
    - [Go Wrapper](#go-wrapper)
  - [Usage](#usage)
    - [Basic Usage](#basic-usage)
    - [Build Flags](#build-flags)
    - [Go Releases](#go-releases)
    - [Limit Build Targets](#limit-build-targets)
    - [Platform Versions](#platform-versions)
    - [CGO Dependencies](#cgo-dependencies)
    - [Hooks](#hooks)
  - [Supporters](#supporters)
  - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)

## Overview

Although Go strives to be a cross-platform language, cross-compilation with CGO enabled isn't straightforward. You need Go sources bootstrapped to each platform and architecture, plus access to OS-specific headers and libraries.

xgo solves this by packaging all necessary Go toolchains, C cross compilers, and platform headers/libraries into a single Docker container. This enables seamless cross-compilation of Go code with embedded C/C++ snippets (`CGO_ENABLED=1`) to various platforms and architectures.

## Quick Start

1. Install Docker and pull the xgo image:
   ```bash
   docker pull techknowlogick/xgo:latest
   ```

2. Install the xgo wrapper:
   ```bash
   go install src.techknowlogick.com/xgo@latest
   ```

3. Cross-compile your project:
   ```bash
   cd your-project
   xgo .
   ```

That's it! You'll get binaries for all supported platforms and architectures.

## Installation

### Docker Image

Pull the pre-built Docker image:

```bash
docker pull techknowlogick/xgo:latest
```

### Go Wrapper

Install the xgo command-line wrapper:

```bash
go install src.techknowlogick.com/xgo@latest
```

## Usage

### Basic Usage

Simply specify the import path you want to build:

```bash
$ xgo -out iris-v0.3.2 github.com/project-iris/iris
...

$ ls -al
-rwxr-xr-x  1 root  root   6776500 Nov 24 16:44 iris-v0.3.2-darwin-10.6-386
-rwxr-xr-x  1 root  root   8755532 Nov 24 16:44 iris-v0.3.2-darwin-10.6-amd64
-rwxr-xr-x  1 root  root  10135248 Nov 24 16:44 iris-v0.3.2-linux-386
-rwxr-xr-x  1 root  root  12598472 Nov 24 16:44 iris-v0.3.2-linux-amd64
-rwxr-xr-x  1 root  root  10040464 Nov 24 16:44 iris-v0.3.2-linux-arm
-rwxr-xr-x  1 root  root   7516368 Nov 24 16:44 iris-v0.3.2-windows-4.0-386.exe
-rwxr-xr-x  1 root  root   9549416 Nov 24 16:44 iris-v0.3.2-windows-4.0-amd64.exe
```

For local projects, use paths starting with `.` or `/`:

```bash
xgo .
```

### CLI Flags

xgo supports the following command-line flags:

| Flag | Description | Default |
|------|-------------|---------|
| `-go` | Go release to use for cross compilation | `latest` |
| `-out` | Prefix to use for output naming | Package name |
| `-dest` | Destination folder to put binaries in | Current directory |
| `-pkg` | Sub-package to build if not root import | |
| `-remote` | Version control remote repository to build | |
| `-branch` | Version control branch to build | |
| `-targets` | Comma separated targets to build for | `*/*` (all) |
| `-deps` | CGO dependencies (configure/make based archives) | |
| `-depsargs` | CGO dependency configure arguments | |
| `-image` | Use custom docker image instead of official | |
| `-env` | Comma separated custom environments for docker | |
| `-dockerargs` | Comma separated arguments for docker run | |
| `-volumes` | Volume mounts in format `source:target[:mode]` | |
| `-hooksdir` | Directory with user hook scripts | |
| `-ssh` | Enable ssh agent forwarding | `false` |

### Build Flags

The following `go build` flags are supported:

| Flag | Description |
|------|-------------|
| `-v` | Print package names as they are compiled |
| `-x` | Print build commands as compilation progresses |
| `-race` | Enable data race detection (amd64 only) |
| `-tags='tag list'` | Build tags to consider satisfied |
| `-ldflags='flag list'` | Arguments for go tool link |
| `-gcflags='flag list'` | Arguments for go tool compile |
| `-buildmode=mode` | Binary type to produce |
| `-trimpath` | Remove all file system paths from the resulting executable |
| `-buildvcs` | Whether to stamp binaries with version control information |
| `-obfuscate` | Obfuscate build using garble |
| `-garbleflags` | Arguments to pass to garble (e.g. `-seed=random`) |

### Go Releases

Select specific Go versions using the `-go` flag:

```bash
xgo -go go-1.24.x github.com/your-username/your-project
```

Supported release strings:
- `latest` - Latest Go release (default)
- `go-1.24.x` - Latest point release of Go 1.24
- `go-1.24.3` - Specific Go version

### Limit Build Targets

Restrict builds to specific platforms/architectures:

```bash
# Build only ARM Linux binaries
xgo --targets=linux/arm github.com/your-username/your-project

# Build all Windows and macOS binaries
xgo --targets=windows/*,darwin/* github.com/your-username/your-project

# Build ARM binaries for all platforms
xgo --targets=*/arm github.com/your-username/your-project
```

**Supported targets:**
- **Platforms:** `darwin`, `linux`, `windows`, `freebsd`
- **Architectures:** `386`, `amd64`, `arm-5`, `arm-6`, `arm-7`, `arm64`, `mips`, `mipsle`, `mips64`, `mips64le`, `riscv64`

### Platform Versions

Target specific platform versions:

```bash
# Cross-compile to macOS Monterey
xgo --targets=darwin-12.0/* github.com/your-username/your-project

# Cross-compile to Windows 10
xgo --targets=windows-10.0/* github.com/your-username/your-project
```

**Supported platforms:**
- **Windows:** All APIs up to Windows 11 (limited by mingw-w64)
- **macOS:** APIs from 10.6 to latest

### CGO Dependencies

Build projects with external C/C++ library dependencies using `--deps`:

```bash
$ xgo --deps=https://gmplib.org/download/gmp/gmp-6.1.0.tar.bz2  \
    --targets=windows/* github.com/ethereum/go-ethereum/cmd/geth
...

$ ls -al
-rwxr-xr-x 1 root root 16315679 Nov 24 16:39 geth-windows-4.0-386.exe
-rwxr-xr-x 1 root root 19452036 Nov 24 16:38 geth-windows-4.0-amd64.exe
```

Pass arguments to dependency configure scripts:

```bash
$ xgo --deps=https://gmplib.org/download/gmp/gmp-6.1.0.tar.bz2  \
    --targets=ios/* --depsargs=--disable-assembly               \
    github.com/ethereum/go-ethereum/cmd/geth
...

$ ls -al
-rwxr-xr-x 1 root root 14804160 Nov 24 16:32 geth-ios-5.0-arm
```

Supported dependency formats: `.tar`, `.tar.gz`, `.tar.bz2`

### Hooks

Use custom build hooks by providing a hooks directory:

```bash
xgo --hooksdir ./hooks github.com/your-username/your-project
```

Available hook scripts:
- `setup.sh` - Sourced after environment setup (install additional packages)
- `build.sh` - Sourced before each target build

Environment variables in `build.sh`:
- `XGOOS` and `XGOARCH` - Target OS and architecture
- `CC` - C cross compiler for the target
- `HOST` - Target platform identifier
- `PREFIX` - Installation path for built binaries

## Supporters

Thanks to these projects for supporting xgo:

- [Gitea](https://about.gitea.com/) - A painless self-hosted Git service
- [Offen](https://www.offen.dev/) - Fair and lightweight web analytics
- [Vikunja](https://vikunja.io/) - The to-do app to organize your life
- [Woodpecker CI](https://woodpecker-ci.org/) - Simple CI engine with great extensibility

You can [sponsor this project](https://github.com/sponsors/techknowlogick/) to ensure its continued maintenance.

## Contributing

Contributions are welcome! Please feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Special thanks to [@karalabe](https://github.com/karalabe) for starting this project and making Go cross-compilation with CGO seamless.
