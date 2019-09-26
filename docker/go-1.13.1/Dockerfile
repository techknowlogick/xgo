FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1131

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=94f874037b82ea5353f4061e543681a0e79657f787437974214629af8407d124 && \
  \
$BOOTSTRAP_PURE
