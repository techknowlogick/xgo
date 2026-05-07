## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12510

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.25.10.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=42d4f7a32316aa66591eca7e89867256057a4264451aca10570a715b3637ba70;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.25.10.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=654da1f9b50a5d1c2a85ccf8ed405aa89c06e94d18384628bf186f7712677b08;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
