FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1136

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=a1bc06deb070155c4f67c579f896a45eeda5a8fa54f35ba233304074c4abbbbd && \
  \
$BOOTSTRAP_PURE
