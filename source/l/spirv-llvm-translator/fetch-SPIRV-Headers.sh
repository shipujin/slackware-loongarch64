#!/bin/sh

# Copyright 2024  Patrick J. Volkerding, Sebeka, Minnesota, USA
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cd $(dirname $0) ; CWD=$(pwd)

PKGNAM=spirv-llvm-translator
VERSION=${VERSION:-$(echo SPIRV-LLVM-Translator-*.tar.?z* | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
BUILD=${BUILD:-1}

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}

# Automatically determine the architecture we're building on:
MARCH=$( uname -m )
if [ -z "$ARCH" ]; then
  case "$MARCH" in
    i?86)    export ARCH=i686 ;;
    armv7hl) export ARCH=$MARCH ;;
    arm*)    export ARCH=arm ;;
    # Unless $ARCH is already set, use uname -m for all other archs:
    *)       export ARCH=$MARCH ;;
  esac
fi

# If the variable PRINT_PACKAGE_NAME is set, then this script will report what
# the name of the created package would be, and then exit. This information
# could be useful to other scripts.
if [ ! -z "${PRINT_PACKAGE_NAME}" ]; then
  echo "$PKGNAM-$VERSION-$ARCH-$BUILD.txz"
  exit 0
fi

if [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=pentium4 -mtune=generic"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -march=x86-64 -mtune=generic -fPIC"
  LIBDIRSUFFIX="64"
else
  SLKCFLAGS="-O2"
  LIBDIRSUFFIX=""
fi

TMP=${TMP:-/tmp}
PKG=$TMP/package-${PKGNAM}
rm -rf $PKG
mkdir -p $TMP $PKG

cd $TMP
rm -rf SPIRV-LLVM-Translator-${VERSION}
tar xvf $CWD/SPIRV-LLVM-Translator-$VERSION.tar.?z* || exit 1
cd SPIRV-LLVM-Translator-$VERSION || exit 1

# Make sure ownerships and permissions are sane:
chown -R root:root .
find . \
 \( -perm 777 -o -perm 775 -o -perm 711 -o -perm 555 -o -perm 511 \) \
 -exec chmod 755 {} \+ -o \
 \( -perm 666 -o -perm 664 -o -perm 600 -o -perm 444 -o -perm 440 -o -perm 400 \) \
 -exec chmod 644 {} \+

# This git pull needs a specific set of headers. These were obtained by letting
# the build download them, and then tarring them up and pointing to them with
# the -DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR option below.
#tar xf $CWD/SPIRV-Headers.tar.lz

# Build and install:
mkdir -p build
cd build
  cmake \
    -DCMAKE_C_FLAGS:STRING="$SLKCFLAGS" \
    -DCMAKE_CXX_FLAGS:STRING="$SLKCFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_SKIP_RPATH=ON \
    -DLIB_INSTALL_DIR=/usr/lib${LIBDIRSUFFIX} \
    -DMAN_INSTALL_DIR=/usr/man \
    -DSYSCONF_INSTALL_DIR=/etc \
    -DINCLUDE_INSTALL_DIR=/usr/include \
    -DLIB_SUFFIX=${LIBDIRSUFFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    ..

# At this point we have the downloaded headers:
tar cf SPIRV-Headers.tar SPIRV-Headers
plzip -9 SPIRV-Headers.tar
mv SPIRV-Headers.tar.lz $CWD
cd $CWD
echo "Fetched SPIRV-Headers.tar.lz:"
ls -l SPIRV-Headers.tar.lz
