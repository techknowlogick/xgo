## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 1220

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.0.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=f6c8a87aa03b92c4b0bf3d558e28ea03006eb29db78917daec5cfb6ec1046265;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.0.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=6a63fef0e050146f275bf02a0896badfe77c11b6f05499bb647e7bd613a45a10;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
