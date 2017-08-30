#!/bin/bash

# set variable
cd `dirname $0`
PWD0=`pwd`
cd ..

source $PWD0/local.conf

PROJECT_DIR=`pwd`
BUILD_DIR="${PROJECT_DIR}/${LINUX_BUILD_PATH}"

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
	-DCMAKE_BUILD_TYPE=${LINUX_BUILD_TYPE} \
	-DCMAKE_PREFIX_PATH=${LINUX_QT_ROOT}

