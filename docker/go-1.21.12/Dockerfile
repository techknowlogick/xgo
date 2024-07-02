## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 12112

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.12.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=121ab58632787e18ae0caa8ae285b581f9470d0f6b3defde9e1600e211f583c5;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.12.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=94cb3ec4a1e08a00da55c33e63f725be91f10ba743907b5615ef34e54675ba2e;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
