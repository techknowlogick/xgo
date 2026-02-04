## GENERATED. DO NOT EDIT DIRECTLY.
FROM toolchain

ARG TARGETPLATFORM
ENV GO_VERSION=12413

RUN \
if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  export ROOT_DIST=https://dl.google.com/go/go1.24.13.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=1fc94b57134d51669c72173ad5d49fd62afb0f1db9bf3f798fd98ee423f8d730;\
elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
export ROOT_DIST=https://dl.google.com/go/go1.24.13.linux-arm64.tar.gz && \
export ROOT_DIST_SHA=74d97be1cc3a474129590c67ebf748a96e72d9f3a2b6fef3ed3275de591d49b3;\
 else \
echo "Unsupported architecture: $TARGETPLATFORM" && exit 1; \
fi && \
$BOOTSTRAP_PURE
