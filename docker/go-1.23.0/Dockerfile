## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1230

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.0.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=905a297f19ead44780548933e0ff1a1b86e8327bb459e92f9c0012569f76f5e3;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.0.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=62788056693009bcf7020eedc778cdd1781941c6145eab7688bd087bce0f8659;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
