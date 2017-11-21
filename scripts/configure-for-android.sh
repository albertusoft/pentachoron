#!/bin/bash

# set variable
cd `dirname $0`
PWD0=`pwd`
cd ..

source $PWD0/local.conf

PROJECT_DIR=`pwd`
BUILD_DIR="${PROJECT_DIR}/${ANDROID_BUILD_PATH}"

echo
echo "-------------------------------------------------------------------------"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "-------------------------------------------------------------------------"

echo
echo "Configuring project for android build..."

echo "ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}"
echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}"
echo "ANDROID_QT_ROOT=${ANDROID_QT_ROOT}"
echo "ANDROID_JAVA_HOME=${ANDROID_JAVA_HOME}"

echo "_________________________________________________________________________"

# create build directory if not exists
[ -d "${BUILD_DIR}" ] || mkdir -p "${BUILD_DIR}"

# enter into build directory
cd "${BUILD_DIR}"

# run cmake
cmake ${PROJECT_DIR} \
	-DCMAKE_BUILD_TYPE=${ANDROID_BUILD_TYPE} \
	-DCMAKE_PREFIX_PATH="${ANDROID_QT_ROOT}" \
	-DCMAKE_TOOLCHAIN_FILE="${PROJECT_DIR}/cmake/Android/AndroidToolchain.cmake" \
	-DLIBRARY_OUTPUT_PATH_ROOT="${BUILD_DIR}/LIBS" \
	-DJAVA_HOME="${ANDROID_JAVA_HOME}" \
	-DANDROID_NDK="${ANDROID_NDK_ROOT}" \
	-DANDROID_SDK="${ANDROID_SDK_ROOT}" \
	-DANDROID_STANDALONE_TOOLCHAIN="${ANDROID_ARM_TOOLCHAIN}" \
	-DANDROID_NATIVE_API_LEVEL="${ANDROID_API_LEVEL}" \
	-DANDROID_ABI="armeabi-v7a" \
	-DANDROID_STL="gnustl_shared" \
	-DANDROID=True

