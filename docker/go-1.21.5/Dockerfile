## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1215

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=e2bc0b3e4b64111ec117295c088bde5f00eeed1567999ff77bc859d7df70078e;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.5.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=841cced7ecda9b2014f139f5bab5ae31785f35399f236b8b3e75dff2a2978d96;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
