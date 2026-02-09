# Go cross compiler (xgo): Base cross-compilation layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.
ARG VERSION=latest
FROM ${VERSION}-base

LABEL maintainer="techknowlogick <techknowlogick@gitea.com>"

COPY go.mod go.sum /xgo-src/
COPY *.go /xgo-src/

# Mark the image as xgo enabled to support xgo-in-xgo
ENV XGO_IN_XGO=1

# Install xgo within the container to enable internal cross compilation
WORKDIR /xgo-src
RUN \
  echo "Installing xgo-in-xgo..." && \
  go mod download && \
  go install . && \
  ln -s /go/bin/xgo /usr/bin/xgo && \
  rm -r /xgo-src

WORKDIR /

# Inject the container entry point, the build script
COPY docker/build/build.sh /build.sh
ENV BUILD=/build.sh
RUN chmod +x "$BUILD"

ENTRYPOINT ["/build.sh"]
