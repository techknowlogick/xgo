FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11216

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.12.16.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=bf3a85d75658144c06ce986ba05e07ef08af4320089b74b1d41de3b0f340ea7e && \
  \
$BOOTSTRAP_PURE
