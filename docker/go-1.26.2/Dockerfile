## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1262

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.26.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=990e6b4bbba816dc3ee129eaeaf4b42f17c2800b88a2166c265ac1a200262282;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.26.2.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=c958a1fe1b361391db163a485e21f5f228142d6f8b584f6bef89b26f66dc5b23;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
