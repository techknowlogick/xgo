## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1259

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.9.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=00859d7bd6defe8bf84d9db9e57b9a4467b2887c18cd93ae7460e713db774bc1;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.9.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=ec342e7389b7f489564ed5463c63b16cf8040023dabc7861256677165a8c0e2b;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
