## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12412

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.12.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=bddf8e653c82429aea7aec2520774e79925d4bb929fe20e67ecc00dd5af44c50;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.12.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=4e02e2979e53b40f3666bba9f7e5ea0b99ea5156e0824b343fd054742c25498d;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
