## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12514

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.14.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=a21ae5633a269bcd7e90cf767e48225633795e99d831742cbf3397064fee7712;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.14.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=9bf234ea70ffec9347fdf6b22ce4add51717d3386a38a441e8c8743fceb5eaee;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
