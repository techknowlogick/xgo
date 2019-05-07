FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1125

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.5.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=aea86e3c73495f205929cfebba0d63f1382c8ac59be081b6351681415f4063cf && \
  \
$BOOTSTRAP_PURE
