FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11412

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.12.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=fb26f951c88c0685d7df393611189c58e6eabd3c17bdaef37df11355ab8db9d3 && \
  \
$BOOTSTRAP_PURE
