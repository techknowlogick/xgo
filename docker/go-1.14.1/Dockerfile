FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1141

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=2f49eb17ce8b48c680cdb166ffd7389702c0dec6effa090c324804a5cac8a7f8 && \
  \
$BOOTSTRAP_PURE
