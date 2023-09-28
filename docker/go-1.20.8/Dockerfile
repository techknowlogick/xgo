## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1208

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.20.8.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=cc97c28d9c252fbf28f91950d830201aa403836cbed702a05932e63f7f0c7bc4 && \
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.20.8.linux-arm64.tar.gz && \
  export ROOT_DIST_SHA=15ab379c6a2b0d086fe3e74be4599420e66549edf7426a300ee0f3809500f89e && \
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
