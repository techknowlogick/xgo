## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1249

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.9.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=5b7899591c2dd6e9da1809fde4a2fad842c45d3f6b9deb235ba82216e31e34a6;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.9.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=9aa1243d51d41e2f93e895c89c0a2daf7166768c4a4c3ac79db81029d295a540;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
