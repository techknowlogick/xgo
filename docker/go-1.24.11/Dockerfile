## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12411

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.11.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=bceca00afaac856bc48b4cc33db7cd9eb383c81811379faed3bdbc80edb0af65;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.11.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=beaf0f51cbe0bd71b8289b2b6fa96c0b11cd86aa58672691ef2f1de88eb621de;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
