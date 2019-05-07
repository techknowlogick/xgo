FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11110

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.10.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=aefaa228b68641e266d1f23f1d95dba33f17552ba132878b65bb798ffa37e6d0 && \
  \
$BOOTSTRAP_PURE
