#!/bin/bash
set -e
################## SETUP BEGIN
THREAD_COUNT=$(sysctl hw.ncpu | awk '{print $2}')
HOST_ARC=$( uname -m )
XCODE_ROOT=$( xcode-select -print-path )
LUA_VER=5.4.5
################## SETUP END
DEVSYSROOT=$XCODE_ROOT/Platforms/iPhoneOS.platform/Developer
SIMSYSROOT=$XCODE_ROOT/Platforms/iPhoneSimulator.platform/Developer
MACSYSROOT=$XCODE_ROOT/Platforms/MacOSX.platform/Developer

BUILD_DIR="$( cd "$( dirname "./" )" >/dev/null 2>&1 && pwd )"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ ! -f "$BUILD_DIR/frameworks.built" ]; then

if [[ $HOST_ARC == arm* ]]; then
    LUA_ARC=arm
elif [[ $HOST_ARC == x86* ]]; then
    LUA_ARC=x86
else
    LUA_ARC=unknown
fi

if [ ! -f lua-$LUA_VER.tar.gz ]; then
    curl -L https://www.lua.org/ftp/lua-$LUA_VER.tar.gz -o lua-$LUA_VER.tar.gz
fi
if [ ! -d lua ]; then
    echo "extracting lua-$LUA_VER.tar.gz ..."
    tar -xf lua-$LUA_VER.tar.gz
    mv lua-$LUA_VER lua
fi

CFLAGS="-std=gnu99 -Oz -Wall -Wextra -DLUA_COMPAT_5_3 -DLUA_USE_MACOSX -DLUA_USE_READLINE"

generic_build()
{
    echo "building lua-$1" ...
    cd lua/src
    if [ -d $1 ]; then
        rm -rf $1
    fi
    mkdir $1
    for f in *.c
    do
      echo "Processing $f file..."
      # take action on each file. $f store current file name
      clang $2 $f -o $1/${f%.*}.o -c $CFLAGS
    done
    cd $1
    ar r liblua.a lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o loadlib.o loslib.o lstrlib.o ltablib.o lutf8lib.o linit.o
    cd ../../..
}

generic_double_build()
{
    generic_build "$1-x86_64" "-arch x86_64 $2"
    generic_build "$1-arm64" "-arch arm64 $2"

    if [ -d lua/src/$1 ]; then
        rm -rf lua/src/$1
    fi
    mkdir lua/src/$1
    lipo -create lua/src/$1-arm64/liblua.a lua/src/$1-x86_64/liblua.a -output lua/src/$1/liblua.a
}

build_macos_libs()
{
    generic_double_build macos
}

build_catalyst_libs()
{
    generic_double_build catalyst "--target=$2-apple-ios13.4-macabi -isysroot $MACSYSROOT/SDKs/MacOSX.sdk -I$MACSYSROOT/SDKs/MacOSX.sdk/System/iOSSupport/usr/include/ -isystem $MACSYSROOT/SDKs/MacOSX.sdk/System/iOSSupport/usr/include -iframework $MACSYSROOT/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks -DIOS_BUILD"
}

build_simulator_libs()
{
    generic_double_build simulator "-fembed-bitcode-marker -isysroot $SIMSYSROOT/SDKs/iPhoneSimulator.sdk -mios-simulator-version-min=13.4 -DIOS_BUILD"
}

build_device_libs()
{
    generic_build ios "-arch arm64 -fembed-bitcode -isysroot $DEVSYSROOT/SDKs/iPhoneOS.sdk -mios-version-min=13.4 -DIOS_BUILD"
}

echo "patching lua-$LUA_VER"
if [ ! -f lua/src/loslib.c.orig ]; then
  cp -f lua/src/loslib.c lua/src/loslib.c.orig
else
  cp -f lua/src/loslib.c.orig lua/src/loslib.c
fi
patch -p0 <$SCRIPT_DIR/loslib.c.patch
rm -f lua/src/lua.c lua/src/luac.c


build_macos_libs
build_catalyst_libs
build_simulator_libs
build_device_libs

if [ -d "$BUILD_DIR/frameworks" ]; then
    rm -rf "$BUILD_DIR/frameworks"
fi
mkdir "$BUILD_DIR/frameworks"
mkdir "$BUILD_DIR/frameworks/Headers"
cp lua/src/luaconf.h lua/src/lua.h lua/src/lualib.h lua/src/lauxlib.h "$BUILD_DIR/frameworks/Headers/"

xcodebuild -create-xcframework -library lua/src/macos/liblua.a -library lua/src/catalyst/liblua.a -library lua/src/simulator/liblua.a -library lua/src/ios/liblua.a -output "$BUILD_DIR/frameworks/lua.xcframework"

touch "$BUILD_DIR/frameworks.built"

fi
