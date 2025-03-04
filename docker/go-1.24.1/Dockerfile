## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=1241

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=cb2396bae64183cdccf81a9a6df0aea3bce9511fc21469fb89a0c00470088073;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.1.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=8df5750ffc0281017fb6070fba450f5d22b600a02081dceef47966ffaf36a3af;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
