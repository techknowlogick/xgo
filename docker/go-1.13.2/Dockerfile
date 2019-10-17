FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1132

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=293b41a6ccd735eebcfb4094b6931bfd187595555cecf3e4386e9e119220c0b7 && \
  \
$BOOTSTRAP_PURE
