## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION 12014

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.20.14.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=ff445e48af27f93f66bd949ae060d97991c83e11289009d311f25426258f9c44;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.20.14.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=2096507509a98782850d1f0669786c09727053e9fe3c92b03c0d96f48700282b;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
