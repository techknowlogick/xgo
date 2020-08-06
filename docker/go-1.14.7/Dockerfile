FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1147

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.7.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=4a7fa60f323ee1416a4b1425aefc37ea359e9d64df19c326a58953a97ad41ea5 && \
  \
$BOOTSTRAP_PURE
