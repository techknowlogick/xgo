## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1211

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=b3075ae1ce5dab85f89bc7905d1632de23ca196bd8336afd93fa97434cfa55ae && \
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.21.1.linux-arm64.tar.gz && \
  export ROOT_DIST_SHA=7da1a3936a928fd0b2602ed4f3ef535b8cd1990f1503b8d3e1acc0fa0759c967 && \
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
