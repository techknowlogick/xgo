FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11213

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.12.13.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=da036454cb3353f9f507f0ceed4048feac611065e4e1818b434365eb32ac9bdc && \
  \
$BOOTSTRAP_PURE
