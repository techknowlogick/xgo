## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1235

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.23.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=cbcad4a6482107c7c7926df1608106c189417163428200ce357695cc7e01d091;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.23.5.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=47c84d332123883653b70da2db7dd57d2a865921ba4724efcdf56b5da7021db0;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
