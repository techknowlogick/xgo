FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11312

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.12.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=9cacc6653563771b458c13056265aa0c21b8a23ca9408278484e4efde4160618 && \
  \
$BOOTSTRAP_PURE
