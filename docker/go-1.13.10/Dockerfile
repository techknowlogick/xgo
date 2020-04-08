FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11310

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=8a4cbc9f2b95d114c38f6cbe94a45372d48c604b707db2057c787398dfbf8e7f && \
  \
$BOOTSTRAP_PURE
