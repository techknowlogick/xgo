FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1150

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.15.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=2d75848ac606061efe52a8068d0e647b35ce487a15bb52272c427df485193602 && \
  \
$BOOTSTRAP_PURE
