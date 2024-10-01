## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1228

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.8.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=5f467d29fc67c7ae6468cb6ad5b047a274bae8180cac5e0b7ddbfeba3e47e18f;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.8.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=5c616b32dab04bb8c4c8700478381daea0174dc70083e4026321163879278a4a;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
