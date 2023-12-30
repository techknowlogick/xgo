# Go cross compiler (xgo): toolchain cross-compilation layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
# Copyright (c) 2019 techknowlogick
#
# Released under the MIT license.

FROM ubuntu:20.04

LABEL maintainer="techknowlogick <techknowlogick@gitea.io>"

# Configure the Go environment, since it's not going to change
ENV PATH   /usr/local/go/bin:$PATH
ENV GOPATH /go
ENV DEBIAN_FRONTEND=noninteractive

# Inject the remote file fetcher and checksum verifier
COPY fetch.sh /fetch.sh
ENV FETCH /fetch.sh
RUN chmod +x $FETCH

# Make sure apt-get is up to date and dependent packages are installed
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# trunk-ignore(hadolint/DL3008)
# trunk-ignore(hadolint/DL3015)
RUN apt-get update
# the following cross-compilations are not supported on arm64 due to missing ubuntu libs:
# - mips*
RUN if [ $(arch) = "aarch64" ] ; then apt-get install -y \
  gcc-multilib-x86-64-linux-gnu gcc-9-multilib-x86-64-linux-gnu \
  gcc-arm-linux-gnueabihf; fi
RUN if [ $(arch) = "x86_64" ] ; then apt-get install -y gcc-arm-linux-gnueabihf \
  gcc-mips64-linux-gnuabi64 gcc-mips64el-linux-gnuabi64 gcc-mipsel-linux-gnu \
  g++-mipsel-linux-gnu gcc-mips-linux-gnu g++-mips-linux-gnu \
  g++-mips64el-linux-gnuabi64 g++-mips64-linux-gnuabi64 g++-9-mips-linux-gnu \
  g++-9-mips64-linux-gnuabi64 gcc-9-mips-linux-gnu gcc-9-mips64-linux-gnuabi64 \
  g++-9-mips64el-linux-gnuabi64 gcc-9-mips64el-linux-gnuabi64 \
  g++-9-mipsel-linux-gnu; fi

RUN apt-get update -y && apt-get install -y automake autogen build-essential bzr \
  ca-certificates clang cmake cpio curl g++-mingw-w64 g++-powerpc64le-linux-gnu \
  g++-s390x-linux-gnu gcc-mingw-w64 gcc-powerpc64le-linux-gnu gcc-riscv64-linux-gnu \
  gcc-s390x-linux-gnu git help2man libc6-dev-arm64-cross libc6-dev-armel-cross \
  libc6-dev-armhf-cross libc6-dev-mips-cross libc6-dev-mipsel-cross \
  libc6-dev-powerpc-ppc64-cross libc6-dev-riscv64-cross libc6-dev-s390x-cross \
  libgmp-dev libssl-dev libssl1.1 libtool libxml2-dev llvm-dev mercurial \
  openjdk-8-jdk openssl p7zip pkg-config swig texinfo unzip ca-certificates \
  uuid-dev wget xz-utils zip zlib1g-dev && apt-get clean && rm -rf \
  /var/lib/apt/lists/* /tmp/* /var/tmp/* && find /var/log -type f | while read -r f; \
  do echo -ne '' > "$f"; done;

RUN \
  # Fix any stock package issues
  ln -s /usr/include/asm-generic /usr/include/asm && \
  # Fix git safe.directory
  git config --global --add safe.directory '*'

# Add patches directory for patching later
COPY patches /patches

##########################
# Darwin Toolchain build #
##########################

# Configure the container for OSX cross compilation
ENV OSX_SDK MacOSX11.1.sdk
ENV OSX_SDK_PATH https://github.com/phracker/MacOSX-SDKs/releases/download/11.0-11.1/${OSX_SDK}.tar.xz

# Make libxar known to the ld64 and cctools build
ENV LD_LIBRARY_PATH=/osxcross/target/lib

# Download the osx sdk and build the osx toolchain
# We download the osx sdk, patch it and pack it again to be able to throw the patched version at osxcross
RUN \
  $FETCH $OSX_SDK_PATH 9b86eab03176c56bb526de30daa50fa819937c54b280364784ce431885341bf6 && \
  tar -xf "$(basename $OSX_SDK_PATH)" && rm -f "$(basename $OSX_SDK_PATH)"
ADD patch.tar.xz $OSX_SDK/usr/include/c++
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# trunk-ignore(hadolint/DL3003)
RUN tar -cf - $OSX_SDK/ | xz -c - > $OSX_SDK.tar.xz && rm -rf $OSX_SDK && \
  # Get a cross compiler
  mkdir osxcross && cd osxcross && git init && \
  git remote add origin https://github.com/tpoechtrager/osxcross.git && \
  git fetch --depth 1 origin 0f87f567dfaf98460244471ad6c0f4311d62079c && \
  git checkout FETCH_HEAD && cd ../ && \
  # Move the SDK in to the cross compiler
  mv $OSX_SDK.tar.xz /osxcross/tarballs/ && \
  # Actually build the toolchain
  OSX_VERSION_MIN=10.13 UNATTENDED=1 LD_LIBRARY_PATH=/osxcross/target/lib /osxcross/build.sh

ENV PATH /osxcross/target/bin:$PATH

###########################
# FREEBSD TOOLCHAIN BUILD #
###########################

COPY prep_freebsd.sh /prep_freebsd.sh
RUN chmod +x /prep_freebsd.sh && \
  /prep_freebsd.sh

ENV PATH /freebsdcross/x86_64-pc-freebsd12/bin:$PATH

# Inject the new Go root distribution downloader and bootstrapper
COPY bootstrap_pure.sh /bootstrap_pure.sh
ENV BOOTSTRAP_PURE /bootstrap_pure.sh
RUN chmod +x $BOOTSTRAP_PURE

# Inject the C dependency cross compiler
COPY build_deps.sh /build_deps.sh
ENV BUILD_DEPS /build_deps.sh
RUN chmod +x $BUILD_DEPS

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
