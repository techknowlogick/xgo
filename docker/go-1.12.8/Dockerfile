FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1128

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.8.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=bd26cd4962a362ed3c11835bca32c2e131c2ae050304f2c4df9fa6ded8db85d2 && \
  \
$BOOTSTRAP_PURE
