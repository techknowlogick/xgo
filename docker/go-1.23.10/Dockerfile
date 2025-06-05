## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12310

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.10.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=535f9f81802499f2a7dbfa70abb8fda3793725fcc29460f719815f6e10b5fd60;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.10.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=bfb1f1df7173f44648ee070a39ab0481068632f595305a699d89cd56a33b8081;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
