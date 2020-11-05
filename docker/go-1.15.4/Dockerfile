FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1154

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.15.4.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=eb61005f0b932c93b424a3a4eaa67d72196c79129d9a3ea8578047683e2c80d5 && \
  \
$BOOTSTRAP_PURE
