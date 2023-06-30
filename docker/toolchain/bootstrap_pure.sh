#!/bin/bash
#
# Contains the Go tool-chain pure-Go bootstrapper, that as of Go 1.5, initiates
# not only a few pre-built Go cross compilers, but rather bootstraps all of the
# supported platforms from the origin Linux amd64 distribution.
#
# Usage: bootstrap_pure.sh
#
# Environment variables for remote bootstrapping:
#   FETCH         - Remote file fetcher and checksum verifier (injected by image)
#   ROOT_DIST     - 64 bit Linux Go binary distribution package
#   ROOT_DIST_SHA - 64 bit Linux Go distribution package checksum
#
# Environment variables for local bootstrapping:
#   GOROOT - Path to the lready installed Go runtime
set -e

# Download, verify and install the root distribution if pulled remotely
if [ "$GOROOT" == "" ]; then
  $FETCH "$ROOT_DIST" "$ROOT_DIST_SHA"

  tar -C /usr/local -xzf "$(basename "$ROOT_DIST")"
  rm -f "$(basename "$ROOT_DIST")"

  export GOROOT=/usr/local/go
fi
export GOROOT_BOOTSTRAP=$GOROOT

GO_VERSION_MAJOR=$(go version | sed -e 's/.*go\([0-9]\+\)\..*/\1/')
GO_VERSION_MINOR=$(go version | sed -e 's/.*go[0-9]\+\.\([0-9]\+\)\..*/\1/')

if [ "$GO_VERSION_MAJOR" -lt 1 ] || { [ "$GO_VERSION_MAJOR" == 1 ] && [ "$GO_VERSION_MINOR" -lt 20 ]; }; then
  # Pre-build all guest distributions based on the root distribution
  echo "Bootstrapping linux/386..."
  GOOS=linux GOARCH=386 CGO_ENABLED=1 go install std

  echo "Bootstrapping linux/arm64..."
  GOOS=linux GOARCH=arm64 CGO_ENABLED=1 CC=aarch64-linux-gnu-gcc-9 go install std

  echo "Bootstrapping linux/mips64..."
  GOOS=linux GOARCH=mips64 CGO_ENABLED=1 CC=mips64-linux-gnuabi64-gcc-9 go install std

  echo "Bootstrapping linux/mips64le..."
  GOOS=linux GOARCH=mips64le CGO_ENABLED=1 CC=mips64el-linux-gnuabi64-gcc-9 go install std

  echo "Bootstrapping linux/mips..."
  GOOS=linux GOARCH=mips CGO_ENABLED=1 CC=mips-linux-gnu-gcc-9 go install std

  echo "Bootstrapping linux/mipsle..."
  GOOS=linux GOARCH=mipsle CGO_ENABLED=1 CC=mipsel-linux-gnu-gcc-9 go install std

  echo "Bootstrapping linux/ppc64le..."
  GOOS=linux GOARCH=ppc64le CGO_ENABLED=1 CC=powerpc64le-linux-gnu-gcc-9 go install std

  echo "Bootstrapping linux/s390x..."
  GOOS=linux GOARCH=s390x CGO_ENABLED=1 CC=s390x-linux-gnu-gcc-9 go install std

  echo "Bootstrapping linux/riscv64..."
  GOOS=linux GOARCH=riscv64 CGO_ENABLED=1 CC=riscv64-linux-gnu-gcc-9 go install std

  echo "Bootstrapping windows/amd64..."
  GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc go install std

  echo "Bootstrapping windows/386..."
  GOOS=windows GOARCH=386 CGO_ENABLED=1 CC=i686-w64-mingw32-gcc go install std

  echo "Bootstrapping freebsd/amd64..."
  GOOS=freebsd GOARCH=amd64 CGO_ENABLED=1 CC=x86_64-pc-freebsd12-gcc go install std

  echo "Bootstrapping darwin/amd64..."
  GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 CC=o64-clang go install std

  echo "Bootstrapping darwin/arm64..."
  GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 CC=o64-clang go install std

  echo "Bootstrapping linux/arm-5..."
  CC=arm-linux-gnueabi-gcc-9 GOOS=linux GOARCH=arm GOARM=5 CGO_ENABLED=1 CGO_CFLAGS="-march=armv5" CGO_CXXFLAGS="-march=armv5" go install std
  if [ -d "/usr/local/go/pkg/linux_arm" ]; then
    mv /usr/local/go/pkg/linux_arm /usr/local/go/pkg/linux_arm-5
  fi

  echo "Bootstrapping linux/arm-6..."
  CC=arm-linux-gnueabi-gcc-9 GOOS=linux GOARCH=arm GOARM=6 CGO_ENABLED=1 CGO_CFLAGS="-march=armv6" CGO_CXXFLAGS="-march=armv6" go install std
  if [ -d "/usr/local/go/pkg/linux_arm" ]; then
    mv /usr/local/go/pkg/linux_arm /usr/local/go/pkg/linux_arm-6
  fi

  echo "Bootstrapping linux/arm-7..."
  CC=arm-linux-gnueabihf-gcc-9 GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="-march=armv7-a" CGO_CXXFLAGS="-march=armv7-a" go install std
  if [ -d "/usr/local/go/pkg/linux_arm" ]; then
    mv /usr/local/go/pkg/linux_arm /usr/local/go/pkg/linux_arm-7
  fi
else
  echo "Bootstrapping is no longer needed for go 1.20+"

  # Install garble (go1.20+) for obfuscated builds
  echo "Installing garble..."
  go install mvdan.cc/garble@latest
  cp /go/bin/garble /usr/bin/garble
fi
