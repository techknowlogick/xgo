## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1244

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.4.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=77e5da33bb72aeaef1ba4418b6fe511bc4d041873cbf82e5aa6318740df98717;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.4.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=d5501ee5aca0f258d5fe9bfaed401958445014495dc115f202d43d5210b45241;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
