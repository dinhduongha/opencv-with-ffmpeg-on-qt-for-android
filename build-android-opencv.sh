#!/bin/bash

if [ $# -ne 1 ]; then
    echo "error: illegal number of script arguments"
    exit 1
fi

if [ -z $NDK_PATH ]; then
    echo "error: undefined NDK_PATH"
    exit 1
fi

if [ -z $NDK_PLATFORM_LEVEL ]; then
    echo "error: undefined NDK_PLATFORM_LEVEL"
    exit 1
fi

if [ -z $ANDROID_SDK_ROOT ]; then
    echo "error: undefined ANDROID_SDK_ROOT"
    exit 1
fi

if [ -z $CC ]; then
    echo "error: undefined CC"
    exit 1
fi

if [ -z $CXX ]; then
    echo "error: undefined CXX"
    exit 1
fi

BUILD_DIR=build-android-$1

export LD_LIBRARY_PATH=$FFMPEG_SRC_DIR/$BUILD_DIR/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$FFMPEG_SRC_DIR/$BUILD_DIR/lib/pkgconfig
export PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR:$FFMPEG_SRC_DIR/$BUILD_DIR/lib

if [ ! -d opencv ]; then
  git clone https://github.com/opencv/opencv
fi

if [ ! -d opencv_contrib ]; then
  git clone https://github.com/opencv/opencv_contrib
fi

git -C opencv_contrib reset --hard 0915b7eaddba3c06d83e201c9a7595e73801f417
cd opencv
git reset --hard ddbd10c0019f3ee5f43b7902d47e7fc4303a6574
git apply ../opencv-patch.diff

mkdir -p $BUILD_DIR
cd $BUILD_DIR
git clean -d -f -x

cmake -DANDROID_ABI=$1 -DANDROID_NATIVE_API_LEVEL=$NDK_PLATFORM_LEVEL -DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake -DBUILD_opencv_world=ON -DWITH_FFMPEG=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOCS=OFF -DBUILD_opencv_apps=OFF -DBUILD_ANDROID_EXAMPLES=OFF -DBUILD_SHARED_LIBS=ON -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules ..

make clean
make -j $(nproc --all)
make install
