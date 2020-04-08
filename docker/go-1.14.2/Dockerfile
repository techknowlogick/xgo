FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1142

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=6272d6e940ecb71ea5636ddb5fab3933e087c1356173c61f4a803895e947ebb3 && \
  \
$BOOTSTRAP_PURE
