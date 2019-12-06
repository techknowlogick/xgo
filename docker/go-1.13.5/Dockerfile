FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1135

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=512103d7ad296467814a6e3f635631bd35574cab3369a97a323c9a585ccaa569 && \
  \
$BOOTSTRAP_PURE
