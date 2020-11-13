FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1155

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.15.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=9a58494e8da722c3aef248c9227b0e9c528c7318309827780f16220998180a0d && \
  \
$BOOTSTRAP_PURE
