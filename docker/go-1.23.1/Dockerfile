## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1231

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=49bbb517cfa9eee677e1e7897f7cf9cfdbcf49e05f61984a2789136de359f9bd;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.1.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=faec7f7f8ae53fda0f3d408f52182d942cc89ef5b7d3d9f23ff117437d4b2d2f;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
