#!/bin/bash
#
# Android binary build helper script
# usage:
#         <scriptname> <appname> <debug/release>
#
# Before you could upload APK file into playstore ypou have to sign it.
# Generate private key:
#   keytool -genkey -v -keystore <your-store-name.jks> -keyalg RSA -keysize 2048 -validity 99999 --alias apk-release
#   also set environmet variable ANDROID_DEPLOY_QT_SIGN=1 before build process to sign APK file
#

if [ "$#" -lt "2" ]
then
	echo "Usae $0 <appname> [<debug/release>] [<install>]"
	echo "(set ANDROID_DEPLOY_QT_SIGN environmnt variable as necessery)"
	exit
fi

# set variable
cd `dirname $0`
PWD0=`pwd`
cd ..
PROJECT_DIR=`pwd`
source ${PROJECT_DIR}/local.conf

BUILD_DIR="${PROJECT_DIR}/${ANDROID_BUILD_PATH}"

echo
echo "-------------------------------------------------------------------------"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "-------------------------------------------------------------------------"

export ANDROID_DEPLOY_QT_SIGN="1"
export ANDROID_DEPLOY_QT_KEYSTOREPATH="${ANDROID_DEPLOY_QT_KEYSTOREPATH}"
export ANDROID_DEPLOY_QT_CERTIFICATEALIAS="${ANDROID_DEPLOY_QT_CERTIFICATEALIAS}"
export ANDROID_DEPLOY_QT_STOREPASS="${ANDROID_DEPLOY_QT_STOREPASS}"
export ANDROID_DEPLOY_QT_KEYPASS="${ANDROID_DEPLOY_QT_KEYPASS}"

if [ $2 = "release" ]
then
	export ANDROID_BUILD_TYPE="Release"
else
	export ANDROID_BUILD_TYPE="RelWithDebInfo"
fi

cd "$BUILD_DIR"
cmake -DCMAKE_BUILD_TYPE=${ANDROID_BUILD_TYPE} ../..
make $1_build_apk -j7
cd "$BUILD_DIR/APP/$1"

if [ $2 = "release" ]
then
	if [ "$3" = "install" ]
	then
		ant installr
	fi
else # debug
	if [ "$3" = "install" ]
	then
		ant installd
	fi
fi
