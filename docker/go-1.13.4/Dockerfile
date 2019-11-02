FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1134

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=692d17071736f74be04a72a06dab9cac1cd759377bd85316e52b2227604c004c && \
  \
$BOOTSTRAP_PURE
