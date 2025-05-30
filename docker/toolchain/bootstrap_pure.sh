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

# Install garble (go1.20+) for obfuscated builds
echo "Installing garble..."
go install mvdan.cc/garble@latest
cp /go/bin/garble /usr/bin/garble
