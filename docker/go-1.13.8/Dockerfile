FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1138

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=0567734d558aef19112f2b2873caa0c600f1b4a5827930eb5a7f35235219e9d8 && \
  \
$BOOTSTRAP_PURE
