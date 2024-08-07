## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1226

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.6.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=999805bed7d9039ec3da1a53bfbcafc13e367da52aa823cb60b68ba22d44c616;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.6.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=c15fa895341b8eaf7f219fada25c36a610eb042985dc1a912410c1c90098eaf2;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
