#!/bin/bash

set -ev

# If using gcc on mac, actually use it ("gcc" just links to clang, but "gcc-4.8" is gcc, https://github.com/travis-ci/travis-ci/issues/2423)
# Note: This must be here and not in install.sh, because environment variables can't be passed between scripts.
if [ "${CXX}" == "g++" ]; then
  echo Switch to actual g++ and not just the AppleClang symlink
  export CXX="g++-7" CC="gcc-7"
else
  echo Do not switch to actual g++ because we are not g++
fi

# Setup ccache
export PATH="/usr/local/opt/ccache/libexec:$PATH"
export CCACHE_COMPILERCHECK=content
export CCACHE_COMPRESS=1
export CCACHE_SLOPPINESS=include_file_mtime
ccache --max-size=512M
ccache --show-stats

# Detect number of CPU cores
export NUMCORES=`sysctl -n hw.ncpu`
echo Using $NUMCORES cores

echo Using CXX compiler $CXX and C compiler $CC

# Setup target directory
mkdir cmake
cd cmake
cmake --version

# Build
echo Build target: ${BUILD_TARGET}
cmake .. -DBUILD_TESTING=on -DCMAKE_BUILD_TYPE=${BUILD_TARGET}
make -j$NUMCORES

ccache --show-stats

# Test
./test/gitversion/gitversion-test
./test/cpp-utils/cpp-utils-test
./test/parallelaccessstore/parallelaccessstore-test
./test/blockstore/blockstore-test
./test/blobstore/blobstore-test
./test/cryfs/cryfs-test

# TODO Also run once fixed
# ./test/fspp/fspp-test
# ./test/cryfs-cli/cryfs-cli-test
