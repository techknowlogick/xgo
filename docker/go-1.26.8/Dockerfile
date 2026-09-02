## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1268

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.26.8.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=d0f743b33e8d8945e6b1f432edd15785c70507121d6e2a723b21285eddf8b57b;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.26.8.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=211ffced9dcb9633a55eac6364816ec0ddd951389a740e88fa8b3337971bdda0;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
