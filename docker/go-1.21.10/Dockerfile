## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 12110

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.10.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=e330e5d977bf4f3bdc157bc46cf41afa5b13d66c914e12fd6b694ccda65fcf92;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.21.10.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=428e0b9ecab5762b7c2be000ad1be6f432dccfcd99bb8b8aeeb757d987bfda9d;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
