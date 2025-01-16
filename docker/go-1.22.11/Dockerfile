## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12211

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.11.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=0fc88d966d33896384fbde56e9a8d80a305dc17a9f48f1832e061724b1719991;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.11.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=9ebfcab26801fa4cf0627c6439db7a4da4d3c6766142a3dd83508240e4f21031;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
