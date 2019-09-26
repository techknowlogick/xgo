FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11210

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.12.10.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=aaa84147433aed24e70b31da369bb6ca2859464a45de47c2a5023d8573412f6b && \
  \
$BOOTSTRAP_PURE
