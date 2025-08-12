## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1250

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.0.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=2852af0cb20a13139b3448992e69b868e50ed0f8a1e5940ee1de9e19a123b613;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.0.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=05de75d6994a2783699815ee553bd5a9327d8b79991de36e38b66862782f54ae;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
