## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12210

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.22.10.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=736ce492a19d756a92719a6121226087ccd91b652ed5caec40ad6dbfb2252092;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.22.10.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=5213c5e32fde3bd7da65516467b7ffbfe40d2bb5a5f58105e387eef450583eec;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
