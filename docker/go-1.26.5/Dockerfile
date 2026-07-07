## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1265

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.26.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=5c2c3b16caefa1d968a94c1daca04a7ca301a496d9b086e17ad77bb81393f053;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.26.5.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=fe4789e92b1f33358680864bbe8704289e7bb5fc207d80623c308935bd696d49;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
