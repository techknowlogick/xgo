## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1214

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.4.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=73cac0215254d0c7d1241fa40837851f3b9a8a742d0b54714cbdfb3feaf8f0af;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.4.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=ce1983a7289856c3a918e1fd26d41e072cc39f928adfb11ba1896440849b95da;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
