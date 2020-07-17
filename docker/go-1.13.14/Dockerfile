FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11314

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.14.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=32617db984b18308f2b00279c763bff060d2739229cb8037217a49c9e691b46a && \
  \
$BOOTSTRAP_PURE
