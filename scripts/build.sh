#!/bin/bash
set -euo pipefail

################## SETUP BEGIN
THREAD_COUNT=$(sysctl hw.ncpu | awk '{print $2}')
HOST_ARC=$( uname -m )
XCODE_ROOT=$( xcode-select -print-path )
LUA_VER=5.5.1
MACOSX_VERSION_ARM=12.3
MACOSX_VERSION_X86_64=10.13
IOS_VERSION=13.4
IOS_SIM_VERSION=13.4
CATALYST_VERSION=13.4
TVOS_VERSION=13.0
TVOS_SIM_VERSION=13.0
WATCHOS_VERSION=11.0
WATCHOS_SIM_VERSION=11.0
XROS_VERSION=1.0
XROS_SIM_VERSION=1.0
################## SETUP END

XROSSYSROOT=$XCODE_ROOT/Platforms/XROS.platform/Developer
XROSSIMSYSROOT=$XCODE_ROOT/Platforms/XRSimulator.platform/Developer
TVOSSYSROOT=$XCODE_ROOT/Platforms/AppleTVOS.platform/Developer
TVOSSIMSYSROOT=$XCODE_ROOT/Platforms/AppleTVSimulator.platform/Developer
WATCHOSSYSROOT=$XCODE_ROOT/Platforms/WatchOS.platform/Developer
WATCHOSSIMSYSROOT=$XCODE_ROOT/Platforms/WatchSimulator.platform/Developer

BUILD_PLATFORMS_ALL="macosx,macosx-arm64,macosx-x86_64,macosx-both,ios,iossim,iossim-arm64,iossim-x86_64,iossim-both,catalyst,catalyst-arm64,catalyst-x86_64,catalyst-both,xros,xrossim,xrossim-arm64,xrossim-x86_64,xrossim-both,tvos,tvossim,tvossim-both,tvossim-arm64,tvossim-x86_64,watchos,watchossim,watchossim-both,watchossim-arm64,watchossim-x86_64"

LUA_VER_NAME=lua-$LUA_VER
BUILD_DIR="$( cd "$( dirname "./" )" >/dev/null 2>&1 && pwd )"

BUILD_PLATFORMS="macosx,ios,iossim,catalyst"
[[ -d $XROSSYSROOT/SDKs/XROS.sdk ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,xros"
[[ -d $XROSSIMSYSROOT/SDKs/XRSimulator.sdk ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,xrossim"
[[ -d $TVOSSYSROOT/SDKs/AppleTVOS.sdk ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,tvos"
[[ -d $TVOSSIMSYSROOT/SDKs/AppleTVSimulator.sdk ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,tvossim"
[[ -d $WATCHOSSYSROOT/SDKs/WatchOS.sdk ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,watchos"
[[ -d $WATCHOSSIMSYSROOT/SDKs/WatchSimulator.sdk ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,watchossim-both"

REBUILD=false

# parse command line
for i in "$@"; do
  case $i in
    -p=*|--platforms=*)
      BUILD_PLATFORMS="${i#*=},"
      shift # past argument=value
      ;;
    --rebuild)
      REBUILD=true
      shift # past argument with no value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

[[ "$BUILD_PLATFORMS" == *"macosx-both"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,macosx-arm64,macosx-x86_64"
[[ "$BUILD_PLATFORMS" == *"iossim-both"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,iossim-arm64,iossim-x86_64"
[[ "$BUILD_PLATFORMS" == *"catalyst-both"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,catalyst-arm64,catalyst-x86_64"
[[ "$BUILD_PLATFORMS" == *"xrossim-both"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,xrossim-arm64,xrossim-x86_64"
[[ "$BUILD_PLATFORMS" == *"tvossim-both"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,tvossim-arm64,tvossim-x86_64"
[[ "$BUILD_PLATFORMS" == *"watchossim-both"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,watchossim-arm64,watchossim-x86_64"
[[ "$BUILD_PLATFORMS," == *"macosx,"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,macosx-$HOST_ARC"
[[ "$BUILD_PLATFORMS," == *"iossim,"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,iossim-$HOST_ARC"
[[ "$BUILD_PLATFORMS," == *"catalyst,"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,catalyst-$HOST_ARC"
[[ "$BUILD_PLATFORMS," == *"xrossim,"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,xrossim-$HOST_ARC"
[[ "$BUILD_PLATFORMS," == *"tvossim,"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,tvossim-$HOST_ARC"
[[ "$BUILD_PLATFORMS," == *"watchossim,"* ]] && BUILD_PLATFORMS="$BUILD_PLATFORMS,watchossim-$HOST_ARC"

BUILD_PLATFORMS=" ${BUILD_PLATFORMS//,/ } "

for i in $BUILD_PLATFORMS; do :;
if [[ ! ",$BUILD_PLATFORMS_ALL," == *",$i,"* ]]; then
    echo "Unknown platform '$i'"
    exit 1
fi
done

# An interrupted download can leave a partial archive or source tree,
# so validate the files we need and extract into a temporary directory renamed on success.
if [[ ! -f $LUA_VER_NAME/src/Makefile || ! -f $LUA_VER_NAME/src/lua.h ]]; then
    echo downloading $LUA_VER_NAME ...
    rm -rf $LUA_VER_NAME $LUA_VER_NAME.download $LUA_VER_NAME.tar.gz
    curl -fL https://www.lua.org/ftp/$LUA_VER_NAME.tar.gz -o $LUA_VER_NAME.tar.gz
    mkdir $LUA_VER_NAME.download
    tar -xzf $LUA_VER_NAME.tar.gz -C $LUA_VER_NAME.download
    mv $LUA_VER_NAME.download/$LUA_VER_NAME $LUA_VER_NAME
    rm -rf $LUA_VER_NAME.download $LUA_VER_NAME.tar.gz
fi

# the library objects as listed by the upstream Makefile (without the lua and luac programs)
LUA_OBJECTS=$(awk -F= '/^(CORE_O|LIB_O)=/{print $2}' $LUA_VER_NAME/src/Makefile)
COMMON_CFLAGS="-std=gnu99 -O2 -Wall -Wextra -DLUA_COMPAT_5_3"

echo building $LUA_VER_NAME "(-j$THREAD_COUNT)" ...

# (type, arc, sdk, target triple, cflags)
generic_build()
{
    local folder=$BUILD_DIR/build.$1.$2
    if [[ $REBUILD == true ]] || [[ ! -f $folder.success ]] || [[ ! -f $folder/liblua.a ]]; then
        [[ -f $folder.success ]] && rm $folder.success
        [[ -d $folder ]] && rm -rf $folder
        mkdir -p $folder
        echo "building liblua ($1 $2)..."
        local cc="xcrun --sdk $3 clang -target $4 $COMMON_CFLAGS $5"
        for object in $LUA_OBJECTS; do
            echo "$cc -c $LUA_VER_NAME/src/${object/.o/.c} -o $folder/$object"
        done | xargs -P $THREAD_COUNT -I{} sh -c '{}'
        for object in $LUA_OBJECTS; do
            [[ -f $folder/$object ]] || { echo "Failed to compile $object for $1 $2"; exit 1; }
        done
        (cd $folder && xcrun --sdk $3 libtool -static -o liblua.a $LUA_OBJECTS)
        touch $folder.success
    fi
}

build_libs()
{
    [[ -d $BUILD_DIR/build.$1 ]] && rm -rf $BUILD_DIR/build.$1
    mkdir -p $BUILD_DIR/build.$1

    if [[ "$BUILD_PLATFORMS" == *$1-arm64* ]]; then
        if [[ "$BUILD_PLATFORMS" == *$1-x86_64* ]]; then
            lipo -create $BUILD_DIR/build.$1.arm64/liblua.a $BUILD_DIR/build.$1.x86_64/liblua.a -output $BUILD_DIR/build.$1/liblua.a
        else
            cp $BUILD_DIR/build.$1.arm64/liblua.a $BUILD_DIR/build.$1/
        fi
    elif [[ "$BUILD_PLATFORMS" == *$1-x86_64* ]]; then
        cp $BUILD_DIR/build.$1.x86_64/liblua.a $BUILD_DIR/build.$1/
    fi
}

# (type, sdk, os and version, target suffix): the library for both architectures
generic_double_build()
{
    [[ "$BUILD_PLATFORMS" == *$1-arm64* ]] && generic_build $1 arm64 $2 arm64-apple-$3$4 -DLUA_USE_IOS
    [[ "$BUILD_PLATFORMS" == *$1-x86_64* ]] && generic_build $1 x86_64 $2 x86_64-apple-$3$4 -DLUA_USE_IOS
    build_libs $1
}

# macOS keeps the real system(); LUA_USE_READLINE from LUA_USE_MACOSX affects only lua.c
build_macosx_libs()
{
    [[ "$BUILD_PLATFORMS" == *macosx-arm64* ]] && generic_build macosx arm64 macosx arm64-apple-macos$MACOSX_VERSION_ARM -DLUA_USE_MACOSX
    [[ "$BUILD_PLATFORMS" == *macosx-x86_64* ]] && generic_build macosx x86_64 macosx x86_64-apple-macos$MACOSX_VERSION_X86_64 -DLUA_USE_MACOSX
    build_libs macosx
}

# the other platforms have no system(), which LUA_USE_IOS replaces with a stub
[[ "$BUILD_PLATFORMS" == *macosx* ]] && build_macosx_libs
[[ "$BUILD_PLATFORMS" == *catalyst* ]] && generic_double_build catalyst macosx ios$CATALYST_VERSION -macabi
[[ "$BUILD_PLATFORMS" == *iossim* ]] && generic_double_build iossim iphonesimulator ios$IOS_SIM_VERSION -simulator
[[ "$BUILD_PLATFORMS" == *xrossim* ]] && generic_double_build xrossim xrsimulator xros$XROS_SIM_VERSION -simulator
[[ "$BUILD_PLATFORMS" == *tvossim* ]] && generic_double_build tvossim appletvsimulator tvos$TVOS_SIM_VERSION -simulator
[[ "$BUILD_PLATFORMS" == *watchossim* ]] && generic_double_build watchossim watchsimulator watchos$WATCHOS_SIM_VERSION -simulator

[[ "$BUILD_PLATFORMS" == *"ios "* ]] && generic_build ios arm64 iphoneos arm64-apple-ios$IOS_VERSION -DLUA_USE_IOS
[[ "$BUILD_PLATFORMS" == *"xros "* ]] && generic_build xros arm64 xros arm64-apple-xros$XROS_VERSION -DLUA_USE_IOS
[[ "$BUILD_PLATFORMS" == *"tvos "* ]] && generic_build tvos arm64 appletvos arm64-apple-tvos$TVOS_VERSION -DLUA_USE_IOS
[[ "$BUILD_PLATFORMS" == *"watchos "* ]] && generic_build watchos arm64 watchos arm64-apple-watchos$WATCHOS_VERSION -DLUA_USE_IOS

LIBARGS=
[[ "$BUILD_PLATFORMS" == *macosx* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.macosx/liblua.a"
[[ "$BUILD_PLATFORMS" == *catalyst* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.catalyst/liblua.a"
[[ "$BUILD_PLATFORMS" == *iossim* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.iossim/liblua.a"
[[ "$BUILD_PLATFORMS" == *xrossim* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.xrossim/liblua.a"
[[ "$BUILD_PLATFORMS" == *tvossim* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.tvossim/liblua.a"
[[ "$BUILD_PLATFORMS" == *watchossim* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.watchossim/liblua.a"
[[ "$BUILD_PLATFORMS" == *"ios "* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.ios.arm64/liblua.a"
[[ "$BUILD_PLATFORMS" == *"xros "* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.xros.arm64/liblua.a"
[[ "$BUILD_PLATFORMS" == *"tvos "* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.tvos.arm64/liblua.a"
[[ "$BUILD_PLATFORMS" == *"watchos "* ]] && LIBARGS="$LIBARGS -library $BUILD_DIR/build.watchos.arm64/liblua.a"

[[ -d $BUILD_DIR/frameworks ]] && rm -rf $BUILD_DIR/frameworks
mkdir -p $BUILD_DIR/frameworks/Headers
xcodebuild -create-xcframework $LIBARGS -output $BUILD_DIR/frameworks/lua.xcframework
cp $LUA_VER_NAME/src/luaconf.h $LUA_VER_NAME/src/lua.h $LUA_VER_NAME/src/lualib.h $LUA_VER_NAME/src/lauxlib.h $LUA_VER_NAME/src/lua.hpp $BUILD_DIR/frameworks/Headers/
