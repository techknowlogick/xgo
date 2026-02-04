## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1257

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.7.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=12e6d6a191091ae27dc31f6efc630e3a3b8ba409baf3573d955b196fdf086005;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.7.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=ba611a53534135a81067240eff9508cd7e256c560edd5d8c2fef54f083c07129;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
