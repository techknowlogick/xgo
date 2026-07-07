## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12512

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.12.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=234828b7a89e0e303d2556310ee549fbcf253d28de937bac3da13d6294262ac1;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.12.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=8b5884aef89600aef5b0b051fb971f11f49bb996521e911f30f02a66884f7bd2;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
