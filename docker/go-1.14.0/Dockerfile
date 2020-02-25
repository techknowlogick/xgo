FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1140

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.14.0.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=08df79b46b0adf498ea9f320a0f23d6ec59e9003660b4c9c1ce8e5e2c6f823ca && \
  \
$BOOTSTRAP_PURE
