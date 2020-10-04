FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1152

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=b49fda1ca29a1946d6bb2a5a6982cf07ccd2aba849289508ee0f9918f6bb4552 && \
  \
$BOOTSTRAP_PURE
