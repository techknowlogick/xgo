## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1209

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.20.9.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=8921369701afa749b07232d2c34d514510c32dbfd79c65adb379451b5f0d7216;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.20.9.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=da7fca78f85b90b495382cd74b2d0a1c0b6aaa200e7feb27ae7198352b2317fa;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
