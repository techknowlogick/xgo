#!/bin/bash

# big thanks to:
# @mcandre
# @samm-git
# @mcilloni
# @marcelog
# @bijanebrahimi
# for their work on this subject which
# I have been able to expand upon for cgo/golang

freebsd_ver=12
freebsd_full_ver=12.4
binutils_ver=2.39
gmp_ver=6.2.1
mpfr_ver=4.1.1
mpc_ver=1.3.1
gcc_ver=7.5.0

mkdir -p /freebsdcross/x86_64-pc-freebsd${freebsd_ver}

# binutils
mkdir /tmp/freebsdbuild && cd /tmp/freebsdbuild && \
  wget https://ftp.gnu.org/gnu/binutils/binutils-${binutils_ver}.tar.xz && \
  tar -xf binutils-${binutils_ver}.tar.xz && cd binutils-${binutils_ver} && \
  ./configure --enable-libssp --enable-gold --enable-ld \
      --target=x86_64-pc-freebsd${freebsd_ver} --prefix=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} && make -j4 && \
  make install && \
  rm -rf /tmp/freebsdbuild && mkdir /tmp/freebsdbuild

# freebsd specific lbs
cd /tmp/freebsdbuild && \
  wget https://download.freebsd.org/ftp/releases/amd64/${freebsd_full_ver}-RELEASE/base.txz && \
  cd /freebsdcross/x86_64-pc-freebsd${freebsd_ver} && \
  tar -xf /tmp/freebsdbuild/base.txz ./lib/ ./usr/lib/ ./usr/include/ && \
  cd /freebsdcross/x86_64-pc-freebsd${freebsd_ver}/usr/lib && \
  find . -xtype l|xargs ls -l|grep ' /lib/' \
    | awk '{print "ln -sf /freebsdcross/x86_64-pc-freebsd12"$11 " " $9}' \
    | /bin/sh && \
  rm -rf /tmp/freebsdbuild && mkdir /tmp/freebsdbuild

# Compile GMP
cd /tmp/freebsdbuild && \
  wget https://ftp.gnu.org/gnu/gmp/gmp-${gmp_ver}.tar.xz && \
  tar -xf gmp-${gmp_ver}.tar.xz && \
  cd gmp-${gmp_ver} && \
  ./configure --prefix=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --enable-shared --enable-static \
      --enable-fft --enable-cxx --host=x86_64-pc-freebsd${freebsd_ver} && \
  make -j4 && make install && \
  rm -rf /tmp/freebsdbuild && mkdir /tmp/freebsdbuild

# Compile MPFR
cd /tmp/freebsdbuild && \
  wget https://ftp.gnu.org/gnu/mpfr/mpfr-${mpfr_ver}.tar.xz && tar -xf mpfr-${mpfr_ver}.tar.xz && \
  cd mpfr-${mpfr_ver} && \
  ./configure --prefix=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --with-gnu-ld  --enable-static \
      --enable-shared --with-gmp=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --host=x86_64-pc-freebsd${freebsd_ver} && \
  make -j4 && make install && \
  rm -rf /tmp/freebsdbuild && mkdir /tmp/freebsdbuild

# Compile MPC
cd /tmp/freebsdbuild && \
  wget https://ftp.gnu.org/gnu/mpc/mpc-${mpc_ver}.tar.gz  && tar -xf mpc-${mpc_ver}.tar.gz && \
  cd mpc-${mpc_ver} && \
  ./configure --prefix=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --with-gnu-ld --enable-static \
      --enable-shared --with-gmp=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} \
      --with-mpfr=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --host=x86_64-pc-freebsd${freebsd_ver} && \
  make -j4 && make install && \
  rm -rf /tmp/freebsdbuild && mkdir /tmp/freebsdbuild

# gcc (change LD_LIBRARY_PATH to /freebsdcross or something)
cd /tmp/freebsdbuild && \
  wget https://ftp.gnu.org/gnu/gcc/gcc-${gcc_ver}/gcc-${gcc_ver}.tar.xz && \
  tar xf gcc-${gcc_ver}.tar.xz && \
  cd gcc-${gcc_ver} && mkdir build && cd build && \
  ../configure --without-headers --with-gnu-as --with-gnu-ld --disable-nls \
      --enable-languages=c,c++ --enable-libssp --enable-gold --enable-ld \
      --disable-libitm --disable-libquadmath --target=x86_64-pc-freebsd${freebsd_ver} \
      --prefix=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --with-gmp=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} \
      --with-mpc=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --with-mpfr=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} --disable-libgomp \
      --with-sysroot=/freebsdcross/x86_64-pc-freebsd${freebsd_ver}  \
      --with-build-sysroot=/freebsdcross/x86_64-pc-freebsd${freebsd_ver} && \
  cd /tmp/freebsdbuild/gcc-${gcc_ver} && \
  echo '#define HAVE_ALIGNED_ALLOC 1' >> libstdc++-v3/config.h.in && \
  cd /tmp/freebsdbuild/gcc-${gcc_ver}/build && \
  make -j4 && make install && \
  rm -rf /tmp/freebsdbuild
