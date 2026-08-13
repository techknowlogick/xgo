## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12513

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.13.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=39042a078ea9ceebe3ecda4a7188f0f5b96e14a071d27923ba7f40b456e85ae3;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.13.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=adad240fcb6bd180cf973b4b7c747baf4ec81d08b7d40ca35940ee4531971490;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
