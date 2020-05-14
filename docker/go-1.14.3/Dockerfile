FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1143

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.3.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=1c39eac4ae95781b066c144c58e45d6859652247f7515f0d2cba7be7d57d2226 && \
  \
$BOOTSTRAP_PURE
