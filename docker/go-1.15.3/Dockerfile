FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1153

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=010a88df924a81ec21b293b5da8f9b11c176d27c0ee3962dc1738d2352d3c02d && \
  \
$BOOTSTRAP_PURE
