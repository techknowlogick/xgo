## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1221

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=aab8e15785c997ae20f9c88422ee35d962c4562212bb0f879d052a35c8307c7f;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.1.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=e56685a245b6a0c592fc4a55f0b7803af5b3f827aaa29feab1f40e491acf35b8;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
