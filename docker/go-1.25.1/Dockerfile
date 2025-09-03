## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1251

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=7716a0d940a0f6ae8e1f3b3f4f36299dc53e31b16840dbd171254312c41ca12e;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.1.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=65a3e34fb2126f55b34e1edfc709121660e1be2dee6bdf405fc399a63a95a87d;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
