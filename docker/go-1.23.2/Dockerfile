## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1232

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=542d3c1705f1c6a1c5a80d5dc62e2e45171af291e755d591c5e6531ef63b454e;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.2.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=f626cdd92fc21a88b31c1251f419c17782933a42903db87a174ce74eeecc66a9;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
