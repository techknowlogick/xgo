## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1224

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.4.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=ba79d4526102575196273416239cca418a651e049c2b099f3159db85e7bade7d;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.4.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=a8e177c354d2e4a1b61020aca3562e27ea3e8f8247eca3170e3fa1e0c2f9e771;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
