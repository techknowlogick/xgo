# Go cross compiler (xgo): Base cross-compilation layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM ubuntu:18.04

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Mark the image as xgo enabled to support xgo-in-xgo
ENV XGO_IN_XGO 1


# Configure the Go environment, since it's not going to change
ENV PATH   /usr/local/go/bin:$PATH
ENV GOPATH /go


# Inject the remote file fetcher and checksum verifier
ADD fetch.sh /fetch.sh
ENV FETCH /fetch.sh
RUN chmod +x $FETCH


# Make sure apt-get is up to date and dependent packages are installed
RUN \
  apt-get update && \
  apt-get install -y automake autogen build-essential ca-certificates                    \
    gcc-5-arm-linux-gnueabi g++-5-arm-linux-gnueabi libc6-dev-armel-cross                \
    gcc-5-arm-linux-gnueabihf g++-5-arm-linux-gnueabihf libc6-dev-armhf-cross            \
    gcc-5-aarch64-linux-gnu g++-5-aarch64-linux-gnu libc6-dev-arm64-cross                \
    gcc-5-mips-linux-gnu g++-5-mips-linux-gnu libc6-dev-mips-cross                       \
    gcc-5-mipsel-linux-gnu g++-5-mipsel-linux-gnu libc6-dev-mipsel-cross                 \
    gcc-5-mips64-linux-gnuabi64 g++-5-mips64-linux-gnuabi64 libc6-dev-mips64-cross       \
    gcc-5-mips64el-linux-gnuabi64 g++-5-mips64el-linux-gnuabi64 libc6-dev-mips64el-cross \
    gcc-5-multilib g++-5-multilib gcc-mingw-w64 g++-mingw-w64 clang llvm-dev             \
    gcc-6-arm-linux-gnueabi g++-6-arm-linux-gnueabi libc6-dev-armel-cross                \
    gcc-6-arm-linux-gnueabihf g++-6-arm-linux-gnueabihf libc6-dev-armhf-cross            \
    gcc-6-aarch64-linux-gnu g++-6-aarch64-linux-gnu libc6-dev-arm64-cross                \
    gcc-6-mips-linux-gnu g++-6-mips-linux-gnu libc6-dev-mips-cross                       \
    gcc-6-mipsel-linux-gnu g++-6-mipsel-linux-gnu libc6-dev-mipsel-cross                 \
    gcc-6-mips64-linux-gnuabi64 g++-6-mips64-linux-gnuabi64 libc6-dev-mips64-cross       \
    gcc-6-mips64el-linux-gnuabi64 g++-6-mips64el-linux-gnuabi64 libc6-dev-mips64el-cross \
    gcc-6-multilib gcc-7-multilib g++-6-multilib gcc-mingw-w64 g++-mingw-w64 clang llvm-dev \
    libtool libxml2-dev uuid-dev libssl-dev swig openjdk-8-jdk pkg-config patch          \
    make xz-utils cpio wget zip unzip p7zip git mercurial bzr texinfo help2man cmake     \
    --no-install-recommends

# Fix any stock package issues
RUN ln -s /usr/include/asm-generic /usr/include/asm

# Add patches directory for patching later
ADD patches /patches

# Configure the container for OSX cross compilation
ENV OSX_SDK     MacOSX10.11.sdk
ENV OSX_NDK_X86 /usr/local/osx-ndk-x86

RUN \
  OSX_SDK_PATH=https://s3.dockerproject.org/darwin/v2/$OSX_SDK.tar.xz && \
  $FETCH $OSX_SDK_PATH dd228a335194e3392f1904ce49aff1b1da26ca62       && \
  tar -xf `basename $OSX_SDK_PATH` && rm -f `basename $OSX_SDK_PATH`

ADD patch.tar.xz $OSX_SDK/usr/include/c++

RUN tar -cf - $OSX_SDK/ | xz -c - > $OSX_SDK.tar.xz && rm -rf $OSX_SDK

RUN  \
  git clone https://github.com/tpoechtrager/osxcross.git && \
  mv  $OSX_SDK.tar.xz /osxcross/tarballs/                && \
  /osxcross/build_clang.sh                                                           && \
  UNATTENDED=1 OSX_VERSION_MIN=10.10 /osxcross/build.sh                              && \
  mv /osxcross/target $OSX_NDK_X86                                                   && \
  rm -rf /osxcross
#  sed -i -e 's|-march=native||g' /osxcross/build_clang.sh /osxcross/wrapper/build.sh && \

ENV PATH $OSX_NDK_X86/bin:$PATH

# Install xar since the macos compiler needs that
RUN apt-get install build-essential libxml2-dev libssl1.0-dev zlib1g-dev -y && \
  wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/xar/xar-1.5.2.tar.gz && \
  tar -zxvf xar-1.5.2.tar.gz  && \
  cd xar-1.5.2 && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf xar-1.5.2

# Inject the old Go package downloader and tool-chain bootstrapper
ADD bootstrap.sh /bootstrap.sh
ENV BOOTSTRAP /bootstrap.sh
RUN chmod +x $BOOTSTRAP

# Inject the new Go root distribution downloader and bootstrapper
ADD bootstrap_pure.sh /bootstrap_pure.sh
ENV BOOTSTRAP_PURE /bootstrap_pure.sh
RUN chmod +x $BOOTSTRAP_PURE

# Inject the Go source distribution downloader and bootstrapper
ADD bootstrap_repo.sh /bootstrap_repo.sh
ENV BOOTSTRAP_REPO /bootstrap_repo.sh
RUN chmod +x $BOOTSTRAP_REPO

# Inject the C dependency cross compiler
ADD build_deps.sh /build_deps.sh
ENV BUILD_DEPS /build_deps.sh
RUN chmod +x $BUILD_DEPS

# Inject the container entry point, the build script
ADD build.sh /build.sh
ENV BUILD /build.sh
RUN chmod +x $BUILD

ENTRYPOINT ["/build.sh"]
