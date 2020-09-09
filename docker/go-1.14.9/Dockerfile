FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1149

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.9.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=f0d26ff572c72c9823ae752d3c81819a81a60c753201f51f89637482531c110a && \
  \
$BOOTSTRAP_PURE
