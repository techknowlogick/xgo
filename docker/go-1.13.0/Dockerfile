FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1130

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=68a2297eb099d1a76097905a2ce334e3155004ec08cdea85f24527be3c48e856 && \
  \
$BOOTSTRAP_PURE
