#!/bin/bash

# set variable
cd `dirname $0`
PWD0=`pwd`
cd ..
PROJECT_DIR=`pwd`
source ${PROJECT_DIR}/local.conf

BUILD_DIR="${PROJECT_DIR}/${IOS_BUILD_PATH}"

echo
echo "-------------------------------------------------------------------------"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "-------------------------------------------------------------------------"

echo
echo "Configuring project for android build..."

# create build directory if not exists
[ -d "${BUILD_DIR}" ] || mkdir -p "${BUILD_DIR}"

# enter into build directory
cd "${BUILD_DIR}"

# run cmake
cmake ${PROJECT_DIR} \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_PREFIX_PATH="${IOS_QT_ROOT}" \
	-DCMAKE_TOOLCHAIN_FILE="${PROJECT_DIR}/cmake/iOS/iOS.cmake" \
	-DLIBRARY_OUTPUT_PATH_ROOT="${BUILD_DIR}/LIBS"

