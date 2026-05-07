## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1263

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.26.3.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=2b2cfc7148493da5e73981bffbf3353af381d5f93e789c82c79aff64962eb556;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.26.3.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=9d89a3ea57d141c2b22d70083f2c8459ba3890f2d9e818e7e933b75614936565;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
