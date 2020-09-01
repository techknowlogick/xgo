FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1148

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.8.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=5504e077a29d0bd6649ca7b66e317f1a4b264e960f74115d6f0f405c49a8e738 && \
  \
$BOOTSTRAP_PURE
