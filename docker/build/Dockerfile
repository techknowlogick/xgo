# Go cross compiler (xgo): Base cross-compilation layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.
ARG VERSION=latest
ARG SHA=latest
FROM ${VERSION}-base

LABEL maintainer="techknowlogick <techknowlogick@gitea.io>"

# Install xgo within the container to enable internal cross compilation
RUN \
  echo "Installing xgo-in-xgo..." && \
  go install src.techknowlogick.com/xgo@"${SHA}" && \
  ln -s /go/bin/xgo /usr/bin/xgo

# Inject the container entry point, the build script
COPY build.sh /build.sh
ENV BUILD /build.sh
RUN chmod +x "$BUILD"

ENTRYPOINT ["/build.sh"]
