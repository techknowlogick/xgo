FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11215

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.12.15.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=61068419f3d3fcd3cc415c352c4a93d6ae0e723ac18a22ac572b4904d78b5a4c && \
  \
$BOOTSTRAP_PURE
