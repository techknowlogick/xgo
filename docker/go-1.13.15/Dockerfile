FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11315

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.15.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=01cc3ddf6273900eba3e2bf311238828b7168b822bb57a9ccab4d7aa2acd6028 && \
  \
$BOOTSTRAP_PURE
