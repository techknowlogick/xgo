## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1247

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.7.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=da18191ddb7db8a9339816f3e2b54bdded8047cdc2a5d67059478f8d1595c43f;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.7.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=fd2bccce882e29369f56c86487663bb78ba7ea9e02188a5b0269303a0c3d33ab;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
