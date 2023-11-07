## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 12011

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.20.11.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=ef79a11aa095a08772d2a69e4f152f897c4e96ee297b0dc20264b7dec2961abe;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.20.11.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=7908a49c6ce9d48af9b5ba76ccaa0769da45d8b635259a01065b3739acef4ada;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
