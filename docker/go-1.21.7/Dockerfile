## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1217

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.7.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=13b76a9b2a26823e53062fa841b07087d48ae2ef2936445dc34c4ae03293702c;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.7.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=a9bc1ccedbfde059f25b3a2ad81ae4cdf21192ae207dfd3ccbbfe99c3749e233;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
