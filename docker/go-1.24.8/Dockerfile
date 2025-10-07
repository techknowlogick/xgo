## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1248

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.8.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=6842c516ca66c89d648a7f1dbe28e28c47b61b59f8f06633eb2ceb1188e9251d;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.8.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=38ac33b4cfa41e8a32132de7a87c6db49277ab5c0de1412512484db1ed77637e;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
