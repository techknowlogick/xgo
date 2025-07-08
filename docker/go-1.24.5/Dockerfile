## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1245

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=10ad9e86233e74c0f6590fe5426895de6bf388964210eac34a6d83f38918ecdc;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.5.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=0df02e6aeb3d3c06c95ff201d575907c736d6c62cfa4b6934c11203f1d600ffa;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
