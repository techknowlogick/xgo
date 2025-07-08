## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12311

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.11.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=80899df77459e0b551d2eb8800ad6eb47023b99cccbf8129e7b5786770b948c5;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.11.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=1085c6ff805ec1f4893fa92013d16e58f74aeac830b1b9919b6908f3ed1a85c5;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
