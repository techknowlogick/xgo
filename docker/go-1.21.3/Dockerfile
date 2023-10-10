## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1213

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.3.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=1241381b2843fae5a9707eec1f8fb2ef94d827990582c7c7c32f5bdfbfd420c8;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.3.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=fc90fa48ae97ba6368eecb914343590bbb61b388089510d0c56c2dde52987ef3;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
