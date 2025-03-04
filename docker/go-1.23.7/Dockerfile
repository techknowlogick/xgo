## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1237

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.7.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=4741525e69841f2e22f9992af25df0c1112b07501f61f741c12c6389fcb119f3;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.7.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=597acbd0505250d4d98c4c83adf201562a8c812cbcd7b341689a07087a87a541;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
