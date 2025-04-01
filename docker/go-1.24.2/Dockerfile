## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1242

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=68097bd680839cbc9d464a0edce4f7c333975e27a90246890e9f1078c7e702ad;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.2.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=756274ea4b68fa5535eb9fe2559889287d725a8da63c6aae4d5f23778c229f4b;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
