## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1225

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=904b924d435eaea086515bc63235b192ea441bd8c9b198c507e85009e6e4c7f0;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.5.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=8d21325bfcf431be3660527c1a39d3d9ad71535fabdf5041c826e44e31642b5a;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
