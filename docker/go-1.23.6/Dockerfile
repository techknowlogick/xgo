## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1236

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.6.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=9379441ea310de000f33a4dc767bd966e72ab2826270e038e78b2c53c2e7802d;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.6.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=561c780e8f4a8955d32bf72e46af0b5ee5e0debe1e4633df9a03781878219202;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
