## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1246

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.6.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=bbca37cc395c974ffa4893ee35819ad23ebb27426df87af92e93a9ec66ef8712;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.6.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=124ea6033a8bf98aa9fbab53e58d134905262d45a022af3a90b73320f3c3afd5;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
