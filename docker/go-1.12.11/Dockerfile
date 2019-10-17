FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11211

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.12.11.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=2c5960292da8b747d83f171a28a04116b2977e809169c344268c893e4cf0a857 && \
  \
$BOOTSTRAP_PURE
