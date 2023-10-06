## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1212

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=f5414a770e5e11c6e9674d4cd4dd1f4f630e176d1828d3427ea8ca4211eee90d;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.2.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=23e208ca44a3cb46cd4308e48a27c714ddde9c8c34f2e4211dbca95b6d456554;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
