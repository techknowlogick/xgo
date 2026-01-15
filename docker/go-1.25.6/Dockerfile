## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1256

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.6.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=f022b6aad78e362bcba9b0b94d09ad58c5a70c6ba3b7582905fababf5fe0181a;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.6.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=738ef87d79c34272424ccdf83302b7b0300b8b096ed443896089306117943dd5;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
