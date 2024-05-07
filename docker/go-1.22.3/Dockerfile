## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1223

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.3.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=8920ea521bad8f6b7bc377b4824982e011c19af27df88a815e3586ea895f1b36;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.3.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=6c33e52a5b26e7aa021b94475587fce80043a727a54ceb0eee2f9fc160646434;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
