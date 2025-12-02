## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1255

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=9e9b755d63b36acf30c12a9a3fc379243714c1c6d3dd72861da637f336ebb35b;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.5.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=b00b694903d126c588c378e72d3545549935d3982635ba3f7a964c9fa23fe3b9;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
