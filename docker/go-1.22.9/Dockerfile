## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1229

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.9.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=84a8f05b7b969d8acfcaf194ce9298ad5d3ddbfc7034930c280006b5c85a574c;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.9.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=5beec5ef9f019e1779727ef0d9643fa8bf2495e7222014d2fc4fbfce5999bf01;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
