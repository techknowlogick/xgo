FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1146

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.6.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=5c566ddc2e0bcfc25c26a5dc44a440fcc0177f7350c1f01952b34d5989a0d287 && \
  \
$BOOTSTRAP_PURE
