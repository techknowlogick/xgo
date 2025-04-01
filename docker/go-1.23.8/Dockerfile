## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1238

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.8.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=45b87381172a58d62c977f27c4683c8681ef36580abecd14fd124d24ca306d3f;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.8.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=9d6d938422724a954832d6f806d397cf85ccfde8c581c201673e50e634fdc992;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
