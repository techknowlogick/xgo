## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1234

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.4.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.4.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=16e5017863a7f6071363782b1b8042eb12c6ca4f4cd71528b2123f0a1275b13e;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
