## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 12111

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.11.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=54a87a9325155b98c85bc04dc50298ddd682489eb47f486f2e6cb0707554abf0;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.11.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=715d9a7ff72e4e0e3378c48318c52c6e4dd32a47c4136f3c08846f89b2ee2241;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
