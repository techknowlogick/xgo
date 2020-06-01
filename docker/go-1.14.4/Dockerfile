FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1144

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=aed845e4185a0b2a3c3d5e1d0a35491702c55889192bb9c30e67a3de6849c067 && \
  \
$BOOTSTRAP_PURE
