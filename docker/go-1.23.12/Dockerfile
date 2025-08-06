## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12312

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.12.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=d3847fef834e9db11bf64e3fb34db9c04db14e068eeb064f49af747010454f90;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.12.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=52ce172f96e21da53b1ae9079808560d49b02ac86cecfa457217597f9bc28ab3;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
