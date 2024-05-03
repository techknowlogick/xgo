## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain2

ARG TARGETPLATFORM
ENV GO_VERSION 1222

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=5901c52b7a78002aeff14a21f93e0f064f74ce1360fce51c6ee68cd471216a17;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.2.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=36e720b2d564980c162a48c7e97da2e407dfcc4239e1e58d98082dfa2486a0c1;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
