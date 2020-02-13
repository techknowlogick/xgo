FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11217

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.12.17.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=a53dd476129d496047487bfd53d021dd17e0c96895865a0e7d0469ce3db8c8d2 && \
  \
$BOOTSTRAP_PURE
