#!/bin/bash
#
# Contains the main cross compiler, that individually sets up each target build
# platform, compiles all the C dependencies, then build the requested executable
# itself.
#
# Usage: build.sh <import path>
#
# Needed environment variables:
#   REPO_REMOTE    - Optional VCS remote if not the primary repository is needed
#   REPO_BRANCH    - Optional VCS branch to use, if not the master branch
#   DEPS           - Optional list of C dependency packages to build
#   ARGS           - Optional arguments to pass to C dependency configure scripts
#   PACK           - Optional sub-package, if not the import path is being built
#   OUT            - Optional output prefix to override the package name
#   FLAG_V         - Optional verbosity flag to set on the Go builder
#   FLAG_X         - Optional flag to print the build progress commands
#   FLAG_RACE      - Optional race flag to set on the Go builder
#   FLAG_TAGS      - Optional tag flag to set on the Go builder
#   FLAG_LDFLAGS   - Optional ldflags flag to set on the Go builder
#   FLAG_GCFLAGS   - Optional gcflags flag to set on the Go builder
#   FLAG_BUILDMODE - Optional buildmode flag to set on the Go builder
#   FLAG_TRIMPATH  - Optional trimpath flag to set on the Go builder
#   FLAG_BUILDVCS  - Optional buildvcs flag to set on the Go builder
#   FLAG_OBFUSCATE - Optional flag to obfuscate builds using garble
#   TARGETS        - Comma separated list of build targets to compile for
#   EXT_GOPATH     - GOPATH elements mounted from the host filesystem
#   GARBLE_FLAGS   - Flags to pass to garble (e.g. -seed=random)

# Define a function that figures out the binary extension
function extension {
  if [ "$FLAG_BUILDMODE" == "archive" ] || [ "$FLAG_BUILDMODE" == "c-archive" ]; then
    if [ "$1" == "windows" ]; then
      echo ".lib"
    else
      echo ".a"
    fi
  elif [ "$FLAG_BUILDMODE" == "shared" ] || [ "$FLAG_BUILDMODE" == "c-shared" ]; then
    if [ "$1" == "windows" ]; then
      echo ".dll"
    elif [ "$1" == "darwin" ]; then
      echo ".dylib"
    else
      echo ".so"
    fi
  else
    if [ "$1" == "windows" ]; then
      echo ".exe"
    fi
  fi
}

function do_build {
    if [ -f "/hooksdir/build.sh" ]; then echo "source build.sh hook"; source "/hooksdir/build.sh"; fi
    # call dedicated build script
    $BUILD_DEPS /deps "${DEPS_ARGS[@]}"
}

GO_VERSION_MAJOR=$(go version | sed -e 's/.*go\([0-9]\+\)\..*/\1/')
GO_VERSION_MINOR=$(go version | sed -e 's/.*go[0-9]\+\.\([0-9]\+\)\..*/\1/')
GO111MODULE=$(go env GO111MODULE)

# if GO_VERSION_MINOR starts with '.' then trim it
if [[ "$GO_VERSION_MINOR" == .* ]]; then
  GO_VERSION_MINOR=${GO_VERSION_MINOR:1}
fi

# Detect if we are using go modules
if [[ "$GO_VERSION_MAJOR" -le 1 && "$GO_VERSION_MINOR" -le 17 ]]; then
  if [[ "$GO111MODULE" == "on" || "$GO111MODULE" == "auto" ]]; then
    USEMODULES=true
  else
    USEMODULES=false
  fi
else
  if [[ "$GO111MODULE" != "off" ]]; then
    USEMODULES=true
  else
    USEMODULES=false
  fi
fi

# Either set a local build environment, or pull any remote imports
if [ "$EXT_GOPATH" != "" ]; then
  # If local builds are requested, inject the sources
  echo "Building locally $1..."
  export GOPATH=$GOPATH:$EXT_GOPATH
  set -e

  # Find and change into the package folder
  cd "$(go list -e -f "{{.Dir}}" "$1")"
  GODEPS_WORKSPACE="$(pwd)/Godeps/_workspace"
  export GOPATH="$GOPATH":"$GODEPS_WORKSPACE"
elif [[ "$USEMODULES" == true && -d /source ]]; then
  # Go module build with a local repository mapped to /source containing at least a go.mod file.

  # Change into the repo/source folder
  cd /source
  echo "Building /source/go.mod..."
else
  # Inject all possible Godep paths to short circuit go gets
  GOPATH_ROOT="$GOPATH/src"
  IMPORT_PATH="$1"
  while [ "$IMPORT_PATH" != "." ]; do
    export GOPATH="$GOPATH":"$GOPATH_ROOT/$IMPORT_PATH"/Godeps/_workspace
    IMPORT_PATH=$(dirname "$IMPORT_PATH")
  done

  # Otherwise download the canonical import path (may fail, don't allow failures beyond)
  echo "Fetching main repository $1..."
  GO111MODULE="off" go get -v -d "$1"
  set -e

  cd "$GOPATH_ROOT/$1"

  # Switch over the code-base to another checkout if requested
  if [ "$REPO_REMOTE" != "" ] || [ "$REPO_BRANCH" != "" ]; then
    # Detect the version control system type
    IMPORT_PATH=$1
    while [ "$IMPORT_PATH" != "." ] && [ "$REPO_TYPE" == "" ]; do
      if [ -d "$GOPATH_ROOT/$IMPORT_PATH/.git" ]; then
        REPO_TYPE="git"
      elif  [ -d "$GOPATH_ROOT/$IMPORT_PATH/.hg" ]; then
        REPO_TYPE="hg"
      fi
      IMPORT_PATH=$(dirname "$IMPORT_PATH")
    done

    if [ "$REPO_TYPE" == "" ]; then
      echo "Unknown version control system type, cannot switch remotes and branches."
      exit 255
    fi
    # If we have a valid VCS, execute the switch operations
    if [ "$REPO_REMOTE" != "" ]; then
      echo "Switching over to remote $REPO_REMOTE..."
      if [ "$REPO_TYPE" == "git" ]; then
        git remote set-url origin "$REPO_REMOTE"
        git fetch --all
        git reset --hard origin/HEAD
        git clean -dxf
      elif [ "$REPO_TYPE" == "hg" ]; then
        echo -e "[paths]\ndefault = $REPO_REMOTE\n" >> .hg/hgrc
        hg pull
      fi
    fi
    if [ "$REPO_BRANCH" != "" ]; then
      echo "Switching over to branch $REPO_BRANCH..."
      if [ "$REPO_TYPE" == "git" ]; then
        git reset --hard "origin/$REPO_BRANCH"
        git clean -dxf
      elif [ "$REPO_TYPE" == "hg" ]; then
        hg checkout "$REPO_BRANCH"
      fi
    fi
  fi
fi

# Download all the C dependencies
mkdir /deps
DEPS=("$DEPS") && for dep in "${DEPS[@]}"; do
  if [ "${dep##*.}" == "tar" ]; then tar -C /deps -x < "/deps-cache/$(basename "$dep")"; fi
  if [ "${dep##*.}" == "gz" ];  then tar -C /deps -xz < "/deps-cache/$(basename "$dep")"; fi
  if [ "${dep##*.}" == "bz2" ]; then tar -C /deps -xj < "/deps-cache/$(basename "$dep")"; fi
done

DEPS_ARGS=("$ARGS")

# Save the contents of the pre-build /usr/local folder for post cleanup
shopt -s nullglob
USR_LOCAL_CONTENTS=(/usr/local/*)
shopt -u nullglob


# Configure some global build parameters
NAME="$OUT"


if [ "$NAME" == "" ]; then
  if [[ "$USEMODULES" = true && -d /source && -f /source/go.mod ]]; then
    NAME="$(sed -n 's/module\ \(.*\)/\1/p' /source/go.mod)"

    if [[ "$NAME" != "" && "$PACK" != "" ]]; then
      NAME="$NAME/$PACK"
    fi
  fi
fi

if [[ "$NAME" == "" ]]; then
  NAME="$(basename "$1/$PACK")"
fi

if [[ "$NAME" == "" || "$NAME" == "." ]]; then
  NAME="main"
fi

# Support go module package
PACK_RELPATH="./$PACK"

if [ "$FLAG_V" == "true" ];    then V=-v; LD+='-v'; fi
if [ "$FLAG_X" == "true" ];    then X=-x; fi
if [ "$FLAG_RACE" == "true" ]; then R=-race; fi
if [ "$FLAG_TAGS" != "" ];     then T=(--tags "$FLAG_TAGS"); fi
if [ "$FLAG_LDFLAGS" != "" ];  then LD=("${LD[@]}" "${FLAG_LDFLAGS[@]}"); fi
if [ "$FLAG_GCFLAGS" != "" ];  then GC=(--gcflags="$(printf "%s " "${FLAG_GCFLAGS[@]}")"); fi

if [ "$FLAG_BUILDMODE" != "" ] && [ "$FLAG_BUILDMODE" != "default" ]; then BM=(--buildmode="${FLAG_BUILDMODE[@]}"); fi
if [ "$FLAG_TRIMPATH" == "true" ]; then TP=-trimpath; fi
if [ "$FLAG_BUILDVCS" != "" ]; then BV=(--buildvcs="$FLAG_BUILDVCS"); fi
if [ "$FLAG_MOD" != "" ]; then MOD=(--mod="$FLAG_MOD"); fi
if [ "$FLAG_OBFUSCATE" == "true" ] && [ "$GO_VERSION_MAJOR" -eq 1 ] && [ "$GO_VERSION_MINOR" -ge 20 ]; then
  if [ "$GARBLE_FLAGS" != "" ]; then
    GOBIN="garble ${GARBLE_FLAGS[@]}"
  else
    GOBIN=garble
  fi
else
  GOBIN=go
fi

# If no build targets were specified, inject a catch all wildcard
if [ "$TARGETS" == "" ]; then
  TARGETS="./."
fi

if [ "${#LD[@]}" -gt 0 ]; then LDF=(--ldflags="$(printf "%s " "${LD[@]}")"); fi

# source setup.sh if existing
if [ -f "/hooksdir/setup.sh" ]; then echo "source setup.sh hook"; source "/hooksdir/setup.sh"; fi

# Build for each requested platform individually
for TARGET in $TARGETS; do
  # Split the target into platform and architecture
  XGOOS=$(echo $TARGET | cut -d '/' -f 1)
  XGOARCH=$(echo $TARGET | cut -d '/' -f 2)

  # Check and build for Linux targets
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "amd64" ]; }; then
    echo "Compiling for linux/amd64..."
    mkdir -p /gocache/linux/amd64
    XGOOS="linux" XGOARCH="amd64" GOCACHE=/gocache/linux/amd64 HOST=x86_64-linux PREFIX=/usr/local do_build
    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/amd64 GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/amd64 CC=x86_64-linux-gnu-gcc CXX=x86_64-linux-gnu-g++ GOOS=linux GOARCH=amd64 CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" $R "${BM[@]}" -o "/build/$NAME-linux-amd64$R$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "386" ]; }; then
    echo "Compiling for linux/386..."
    mkdir -p /gocache/linux/386
    XGOOS="linux" XGOARCH="386" GOCACHE=/gocache/linux/386 CC="gcc -m32" CXX="g++ -m32" HOST=i686-linux PREFIX=/usr/local do_build
    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/386 GOOS=linux GOARCH=386 CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/386 GOOS=linux GOARCH=386 CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-386$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; }  && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "arm" ] || [ "$XGOARCH" == "arm-5" ]; }; then
    mkdir -p /gocache/linux/arm-5
    if [ "$GO_VERSION_MAJOR" -gt 1 ] || { [ "$GO_VERSION_MAJOR" == 1 ] && [ "$GO_VERSION_MINOR" -ge 15 ]; }; then
      ln -s /usr/local/go/pkg/linux_arm-5 /usr/local/go/pkg/linux_arm
    fi
    echo "Compiling for linux/arm-5..."
    XGOOS="linux" XGOARCH="arm-5" GOCACHE=/gocache/linux/arm-5 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ HOST=arm-linux-gnueabihf-gcc PREFIX=/usr/aarch64-linux-gnu CFLAGS="-march=armv5t" CXXFLAGS="-march=armv5t" do_build
    export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/arm-5 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ GOOS=linux GOARCH=arm GOARM=5 CGO_ENABLED=1 CGO_CFLAGS="-march=armv5t" CGO_CXXFLAGS="-march=armv5t" go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/arm-5 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ GOOS=linux GOARCH=arm GOARM=5 CGO_ENABLED=1 CGO_CFLAGS="-march=armv5t" CGO_CXXFLAGS="-march=armv5t" $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-arm-5$(extension linux)" "$PACK_RELPATH"
    if [ "$GO_VERSION_MAJOR" -gt 1 ] || { [ "$GO_VERSION_MAJOR" == 1 ] && [ "$GO_VERSION_MINOR" -ge 15 ]; }; then
      rm /usr/local/go/pkg/linux_arm
    fi
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "arm-6" ]; }; then
    mkdir -p /gocache/linux/arm-6
    ln -s /usr/local/go/pkg/linux_arm-6 /usr/local/go/pkg/linux_arm

    echo "Compiling for linux/arm-6..."
    XGOOS="linux" XGOARCH="arm-6" GOCACHE=/gocache/linux/arm-6 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ HOST=arm-linux-gnueabihf-gcc PREFIX=/usr/aarch64-linux-gnu CFLAGS="-march=armv6" CXXFLAGS="-march=armv6" do_build
    export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/arm-6 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ GOOS=linux GOARCH=arm GOARM=6 CGO_ENABLED=1 CGO_CFLAGS="-march=armv6" CGO_CXXFLAGS="-march=armv6" go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/arm-6 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ GOOS=linux GOARCH=arm GOARM=6 CGO_ENABLED=1 CGO_CFLAGS="-march=armv6" CGO_CXXFLAGS="-march=armv6" $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-arm-6$(extension linux)" "$PACK_RELPATH"

    rm /usr/local/go/pkg/linux_arm
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "arm-7" ]; }; then
    mkdir -p /gocache/linux/arm-7
    ln -s /usr/local/go/pkg/linux_arm-7 /usr/local/go/pkg/linux_arm

    echo "Compiling for linux/arm-7..."
    XGOOS="linux" XGOARCH="arm-7" GOCACHE=/gocache/linux/arm-7 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ HOST=arm-linux-gnueabihf-gcc PREFIX=/usr/aarch64-linux-gnu CFLAGS="-march=armv7-a -fPIC" CXXFLAGS="-march=armv7-a -fPIC" do_build
    export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/arm-7 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="-march=armv7-a -fPIC" CGO_CXXFLAGS="-march=armv7-a -fPIC" go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/arm-7 CC=arm-linux-gnueabihf-gcc CXX=aarch64-linux-gnu-g++ GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="-march=armv7-a -fPIC" CGO_CXXFLAGS="-march=armv7-a -fPIC" $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-arm-7$(extension linux)" "$PACK_RELPATH"

    rm /usr/local/go/pkg/linux_arm
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "arm64" ]; }; then
    echo "Compiling for linux/arm64..."
    mkdir -p /gocache/linux/arm64
    XGOOS="linux" XGOARCH="arm64" GOCACHE=/gocache/linux/arm64 CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ PREFIX=/usr/arm-linux-gnueabihf-gcc/ do_build
    export PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf-gcc/lib/pkgconfig

      if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/arm64 CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ GOOS=linux GOARCH=arm CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/arm64 CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ GOOS=linux GOARCH=arm CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-arm64$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "mips64" ]; }; then
    echo "Compiling for linux/mips64..."
    mkdir -p /gocache/linux/mips64
    XGOOS="linux" XGOARCH="mips64" GOCACHE=/gocache/linux/mips64 CC=mips64-linux-gnuabi64-gcc-9 CXX=mips64-linux-gnuabi64-g++-9 HOST=mips64-linux-gnuabi64 PREFIX=/usr/mips64-linux-gnuabi64 do_build
    export PKG_CONFIG_PATH=/usr/mips64-linux-gnuabi64/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/mips64 CC=mips64-linux-gnuabi64-gcc-9 CXX=mips64-linux-gnuabi64-g++-9 GOOS=linux GOARCH=mips64 CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/mips64 CC=mips64-linux-gnuabi64-gcc-9 CXX=mips64-linux-gnuabi64-g++-9 GOOS=linux GOARCH=mips64 CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-mips64$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "mips64le" ]; }; then
    echo "Compiling for linux/mips64le..."
    mkdir -p /gocache/linux/mips64le
    XGOOS="linux" XGOARCH="mips64le" GOCACHE=/gocache/linux/mips64le CC=mips64el-linux-gnuabi64-gcc-9 CXX=mips64el-linux-gnuabi64-g++-9 HOST=mips64el-linux-gnuabi64 PREFIX=/usr/mips64el-linux-gnuabi64 do_build
    export PKG_CONFIG_PATH=/usr/mips64le-linux-gnuabi64/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/mips64le CC=mips64el-linux-gnuabi64-gcc-9 CXX=mips64el-linux-gnuabi64-g++-9 GOOS=linux GOARCH=mips64le CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/mips64le CC=mips64el-linux-gnuabi64-gcc-9 CXX=mips64el-linux-gnuabi64-g++-9 GOOS=linux GOARCH=mips64le CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-mips64le$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "mips" ]; }; then
    echo "Compiling for linux/mips..."
    mkdir -p /gocache/linux/mips
    XGOOS="linux" XGOARCH="mips" GOCACHE=/gocache/linux/mips CC=mips-linux-gnu-gcc-9 CXX=mips-linux-gnu-g++-9 HOST=mips-linux-gnu PREFIX=/usr/mips-linux-gnu do_build
    export PKG_CONFIG_PATH=/usr/mips-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/mips CC=mips-linux-gnu-gcc-9 CXX=mips-linux-gnu-g++-9 GOOS=linux GOARCH=mips CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/mips CC=mips-linux-gnu-gcc-9 CXX=mips-linux-gnu-g++-9 GOOS=linux GOARCH=mips CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-mips$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "s390x" ]; }; then
    echo "Compiling for linux/s390x..."
    mkdir -p /gocache/linux/s390x
    XGOOS="linux" XGOARCH="s390x" GOCACHE=/gocache/linux/s390x CC=s390x-linux-gnu-gcc-9 CXX=s390x-linux-gnu-g++-9 HOST=s390x-linux-gnu PREFIX=/usr/s390x-linux-gnu do_build
    export PKG_CONFIG_PATH=/usr/s390x-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/s390x CC=s390x-linux-gnu-gcc-9 CXX=s390x-linux-gnu-g++-9 GOOS=linux GOARCH=s390x CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/s390x CC=s390x-linux-gnu-gcc-9 CXX=s390x-linux-gnu-g++-9 GOOS=linux GOARCH=s390x CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-s390x$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "riscv64" ]; }; then
    echo "Compiling for linux/riscv64..."
    mkdir -p /gocache/linux/riscv64
    XGOOS="linux" XGOARCH="riscv64" GOCACHE=/gocache/linux/riscv64 CC=riscv64-linux-gnu-gcc-9 CXX=riscv64-linux-gnu-g++-9 HOST=riscv64-linux-gnu PREFIX=/usr/riscv64-linux-gnu do_build
    export PKG_CONFIG_PATH=/usr/riscv64-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/riscv64 CC=riscv64-linux-gnu-gcc-9 CXX=riscv64-linux-gnu-g++-9 GOOS=linux GOARCH=riscv64 CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/riscv64 CC=riscv64-linux-gnu-gcc-9 CXX=riscv64-linux-gnu-g++-9 GOOS=linux GOARCH=riscv64 CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-riscv64$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "ppc64le" ]; }; then
    echo "Compiling for linux/ppc64le..."
    mkdir -p /gocache/linux/ppc64le
    XGOOS="linux" XGOARCH="ppc64le" GOCACHE=/gocache/linux/ppc64le CC=powerpc64le-linux-gnu-gcc-9 CXX=powerpc64le-linux-gnu-g++-9 HOST=ppc64le-linux-gnu PREFIX=/usr/ppc64le-linux-gnu do_build
    export PKG_CONFIG_PATH=/usr/ppc64le-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/ppc64le CC=powerpc64le-linux-gnu-gcc-9 CXX=powerpc64le-linux-gnu-g++-9 GOOS=linux GOARCH=ppc64le CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/ppc64le CC=powerpc64le-linux-gnu-gcc-9 CXX=powerpc64le-linux-gnu-g++-9 GOOS=linux GOARCH=ppc64le CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-ppc64le$(extension linux)" "$PACK_RELPATH"
  fi
  if { [ "$XGOOS" == "." ] || [ "$XGOOS" == "linux" ]; } && { [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "mipsle" ]; }; then
    echo "Compiling for linux/mipsle..."
    mkdir -p /gocache/linux/mipsle
    XGOOS="linux" XGOARCH="mipsle" GOCACHE=/gocache/linux/mipsle CC=mipsel-linux-gnu-gcc-9 CXX=mipsel-linux-gnu-g++-9 HOST=mipsel-linux-gnu PREFIX=/usr/mipsel-linux-gnu do_build
    export PKG_CONFIG_PATH=/usr/mipsle-linux-gnu/lib/pkgconfig

    if [[ "$USEMODULES" == false ]]; then
      GOCACHE=/gocache/linux/mipsle CC=mipsel-linux-gnu-gcc-9 CXX=mipsel-linux-gnu-g++-9 GOOS=linux GOARCH=mipsle CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
    fi
    GOCACHE=/gocache/linux/mipsle CC=mipsel-linux-gnu-gcc-9 CXX=mipsel-linux-gnu-g++-9 GOOS=linux GOARCH=mipsle CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-linux-mipsle$(extension linux)" "$PACK_RELPATH"
  fi
  # Check and build for Windows targets
  if [ "$XGOOS" == "." ] || [[ "$XGOOS" == windows* ]]; then
    # Split the platform version and configure the Windows NT version
    PLATFORM=$(echo "$XGOOS" | cut -d '-' -f 2)
    if [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ] || [ "$PLATFORM" == "windows" ]; then
      PLATFORM=4.0 # Windows NT
    fi

    MAJOR=$(echo "$PLATFORM" | cut -d '.' -f 1)
    if [ "${PLATFORM/.}" != "$PLATFORM" ] ; then
      MINOR=$(echo "$PLATFORM" | cut -d '.' -f 2)
    fi
    CGO_NTDEF="-D_WIN32_WINNT=0x$(printf "%02d" "$MAJOR")$(printf "%02d" "$MINOR")"

    # Build the requested windows binaries
    if [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "amd64" ]; then
      echo "Compiling for windows-$PLATFORM/amd64..."
      mkdir -p /gocache/windows-$PLATFORM/amd64
      XGOOS="windows-$PLATFORM" XGOARCH="amd64" GOCACHE=/gocache/windows-$PLATFORM/amd64 CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix HOST=x86_64-w64-mingw32 PREFIX=/usr/x86_64-w64-mingw32 do_build
      export PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/lib/pkgconfig

      if [[ "$USEMODULES" == false ]]; then
        GOCACHE=/gocache/windows-$PLATFORM/amd64 CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" go get $V $X "${T[@]}" -d "$PACK_RELPATH"
      fi
      GOCACHE=/gocache/windows-$PLATFORM/amd64 CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" $R "${BM[@]}" -o "/build/$NAME-windows-$PLATFORM-amd64$R$(extension windows)" "$PACK_RELPATH"
    fi
    if [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "386" ]; then
      echo "Compiling for windows-$PLATFORM/386..."
      mkdir -p /gocache/windows-$PLATFORM/386
      XGOOS="windows-$PLATFORM" XGOARCH="386" GOCACHE=/gocache/windows-$PLATFORM/386 CC=i686-w64-mingw32-gcc-posix CXX=i686-w64-mingw32-g++-posix HOST=i686-w64-mingw32 PREFIX=/usr/i686-w64-mingw32 do_build
      export PKG_CONFIG_PATH=/usr/i686-w64-mingw32/lib/pkgconfig

      if [[ "$USEMODULES" == false ]]; then
        GOCACHE=/gocache/windows-$PLATFORM/386 CC=i686-w64-mingw32-gcc-posix CXX=i686-w64-mingw32-g++-posix GOOS=windows GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" go get $V $X "${T[@]}" -d "$PACK_RELPATH"
      fi
      GOCACHE=/gocache/windows-$PLATFORM/386 CC=i686-w64-mingw32-gcc-posix CXX=i686-w64-mingw32-g++-posix GOOS=windows GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-windows-$PLATFORM-386$(extension windows)" "$PACK_RELPATH"
    fi
  fi
  # Check and build for OSX targets
  if [ "$XGOOS" == "." ] || [[ "$XGOOS" == darwin* ]]; then
    # Split the platform version and configure the deployment target
    PLATFORM=$(echo "$XGOOS" | cut -d '-' -f 2)
    if [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ] || [ "$PLATFORM" == "darwin" ]; then
      PLATFORM=10.12 # OS X Sierra (min version support for golang)
    fi
    export MACOSX_DEPLOYMENT_TARGET=$PLATFORM

    # Strip symbol table below Go 1.6 to prevent DWARF issues
    LDS=("${LD[@]}")
    if [ "$GO_VERSION_MAJOR" -lt 1 ] || { [ "$GO_VERSION_MAJOR" == 1 ] && [ "$GO_VERSION_MINOR" -lt 16 ]; }; then
      LDS=("-s" "${LDS[@]}")
    fi
    if [ ${#LDS[@]} -gt 0 ]; then
      LDFS=(--ldflags="$(printf "%s " "${LD[@]}")")
    fi
    # Build the requested darwin binaries
    if [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "amd64" ]; then
      echo "Compiling for darwin-$PLATFORM/amd64..."
      mkdir -p /gocache/darwin-$PLATFORM/amd64
      XGOOS="darwin-$PLATFORM" XGOARCH="amd64" GOCACHE=/gocache/darwin-$PLATFORM/amd64 CC=o64-clang CXX=o64-clang++ HOST=x86_64-apple-darwin15 PREFIX=/usr/local do_build
      if [[ "$USEMODULES" == false ]]; then
        GOCACHE=/gocache/darwin-$PLATFORM/amd64 CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go get $V $X "${T[@]}" "${LDFS[@]}" "${GC[@]}" -d "$PACK_RELPATH"
      fi
      GOCACHE=/gocache/darwin-$PLATFORM/amd64 CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDFS[@]}" "${GC[@]}" $R "${BM[@]}" -o "/build/$NAME-darwin-$PLATFORM-amd64$R$(extension darwin)" "$PACK_RELPATH"
    fi
    if [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "arm64" ]; then
      if [ "$GO_VERSION_MAJOR" -lt 1 ] || { [ "$GO_VERSION_MAJOR" == 1 ] && [ "$GO_VERSION_MINOR" -lt 16 ]; }; then
        echo "Go version too low, skipping darwin-$PLATFORM/arm64..."
      else
        echo "Compiling for darwin-$PLATFORM/arm64..."
        mkdir -p /gocache/darwin-$PLATFORM/arm64
        XGOOS="darwin-$PLATFORM" XGOARCH="arm64" GOCACHE=/gocache/darwin-$PLATFORM/arm64 CC=o64-clang CXX=o64-clang++ HOST=arm64-apple-darwin15 PREFIX=/usr/local do_build
        if [[ "$USEMODULES" == false ]]; then
          GOCACHE=/gocache/darwin-$PLATFORM/arm64 CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 go get $V $X "${T[@]}" "${LDFS[@]}" "${GC[@]}" -d "$PACK_RELPATH"
        fi
        GOCACHE=/gocache/darwin-$PLATFORM/arm64 CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDFS[@]}" "${GC[@]}" $R "${BM[@]}" -o "/build/$NAME-darwin-$PLATFORM-arm64$R$(extension darwin)" "$PACK_RELPATH"
      fi
    fi
    # Remove any automatically injected deployment target vars
    unset MACOSX_DEPLOYMENT_TARGET
  fi
  # Check and build for freebsd targets
  if [ "$XGOOS" == "." ] || [[ "$XGOOS" == freebsd* ]]; then
    # Build the requested freebsd binaries
    if [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "amd64" ]; then
      echo "Compiling for freebsd/amd64..."
      XGOOS="freebsd" XGOARCH="amd64" CC=x86_64-pc-freebsd12-gcc HOST=x86_64-pc-freebsd12 PREFIX=/freebsdcross/x86_64-pc-freebsd12 do_build
      export PKG_CONFIG_PATH=/freebsdcross/x86_64-pc-freebsd12/lib/pkgconfig

       if [[ "$USEMODULES" == false ]]; then
        CC=x86_64-pc-freebsd12-gcc CXX=x86_64-pc-freebsd12-g++ GOOS=freebsd GOARCH=amd64 CGO_ENABLED=1 go get $V $X "${T[@]}" -d "$PACK_RELPATH"
      fi
      CC=x86_64-pc-freebsd12-gcc CXX=x86_64-pc-freebsd12-g++ GOOS=freebsd GOARCH=amd64 CGO_ENABLED=1 $GOBIN build $V $X $TP $BV "${MOD[@]}" "${T[@]}" "${LDF[@]}" "${GC[@]}" "${BM[@]}" -o "/build/$NAME-freebsd12-amd64$(extension freebsd)" "$PACK_RELPATH"
    fi
    if [ "$XGOARCH" == "." ] || [ "$XGOARCH" == "arm64" ]; then
      echo "skipping freebsd/arm64... as it is not yet supported"
      # TODO: add arm64 support
    fi
  fi
done

# Clean up any leftovers for subsequent build invocations
echo "Cleaning up build environment..."
rm -rf /deps

for dir in /usr/local/*; do
  keep=0

  # Check against original folder contents
  for old in "${USR_LOCAL_CONTENTS[@]}"; do
    if [ "$old" == "$dir" ]; then
      keep=1
    fi
  done
  # Delete anything freshly generated
  if [ "$keep" == "0" ]; then
    rm -rf "$dir"
  fi
done

# set owner of created executables to owner of the /build directory (all executables and created directories start with $NAME)
chown -R --reference /build /build/"$NAME"*
