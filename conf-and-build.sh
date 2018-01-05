#!/bin/bash
#
# Configuration and build helper script
# usage:
#         conf-and-buid.sh <platform[-build]>
#
#   platform: linux (default), android, android, macos, ios
#
# Notes form ANDROID buid:
#   Before you could upload APK file into playstore ypou have to sign it.
#   Generate private key:
#     keytool -genkey -v -keystore <your-store-name.jks> -keyalg RSA -keysize 2048 -validity 99999 --alias apk-release
#     also set environmet variable ANDROID_DEPLOY_QT_SIGN=1 before build process to sign APK file
#

if [ "$#" -lt "1" ]
then
	TARGET_PLATFORM="linux"
else
	TARGET_PLATFORM=$1
fi

# set variables
cd `dirname $0`
PROJECT_DIR=`pwd`
source ${PROJECT_DIR}/app.conf
source ${PROJECT_DIR}/local.conf

BUILD_DIR="${PROJECT_DIR}/${LINUX_BUILD_PATH}"
NUMBER_OF_CPU_CORES=`getconf _NPROCESSORS_ONLN`

case "${TARGET_PLATFORM}" in
	linux|linux-build) BUILD_DIR="${PROJECT_DIR}/${LINUX_BUILD_PATH}" ;;
	android|android-build|android-install) BUILD_DIR="${PROJECT_DIR}/${ANDROID_BUILD_PATH}" ;;
	macos) BUILD_DIR="${PROJECT_DIR}/${MACOS_BUILD_PATH}" ;;
	ios) BUILD_DIR="${PROJECT_DIR}/${IOS_BUILD_PATH}" ;;
	*) echo "Given target platform '${TARGET_PLATFORM}' is not supported."; exit ;;
esac

echo
echo "-------------------------------------------------------------------------"
echo "PROJECT_DIR=${PROJECT_DIR}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "NUMBER_OF_CPU_CORES=${NUMBER_OF_CPU_CORES}"
echo "-------------------------------------------------------------------------"

# create build directory if not exists
[ -d "${BUILD_DIR}" ] || mkdir -p "${BUILD_DIR}"

# enter into build directory
cd "${BUILD_DIR}"

# run cmake
case "${TARGET_PLATFORM}" in

	linux)
		echo "Configuring project for LINUX build..."
		echo "LINUX_QT_ROOT=${LINUX_QT_ROOT}"
		echo "_________________________________________________________________________"
		cmake ${PROJECT_DIR} \
			-DCMAKE_BUILD_TYPE=${LINUX_BUILD_TYPE} \
			-DCMAKE_PREFIX_PATH=${LINUX_QT_ROOT} \
		;;

	linux-build)

		cd "$BUILD_DIR"
		cmake -DCMAKE_BUILD_TYPE=${LINUX_BUILD_TYPE} ../..
		make all -j${NUMBER_OF_CPU_CORES}
		;;

	android)
		echo "Configuring project for ANDROID build..."
		echo "ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}"
		echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}"
		echo "ANDROID_QT_ROOT=${ANDROID_QT_ROOT}"
		echo "ANDROID_JAVA_HOME=${ANDROID_JAVA_HOME}"
		echo "_________________________________________________________________________"
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
		;;

	android-build)

		export ANDROID_DEPLOY_QT_SIGN="1"
		export ANDROID_DEPLOY_QT_KEYSTOREPATH="${ANDROID_DEPLOY_QT_KEYSTOREPATH}"
		export ANDROID_DEPLOY_QT_CERTIFICATEALIAS="${ANDROID_DEPLOY_QT_CERTIFICATEALIAS}"
		export ANDROID_DEPLOY_QT_STOREPASS="${ANDROID_DEPLOY_QT_STOREPASS}"
		export ANDROID_DEPLOY_QT_KEYPASS="${ANDROID_DEPLOY_QT_KEYPASS}"
		export ANDROID_BUILD_TYPE="Release"

		cd "$BUILD_DIR"
		cmake -DCMAKE_BUILD_TYPE=${ANDROID_BUILD_TYPE} ../..
		make ${APP_NAME,,}_build_apk -j${NUMBER_OF_CPU_CORES}
		;;

	android-install)
		cd "$BUILD_DIR"
		adb install "$BUILD_DIR/APP/${APP_NAME,,}/bin/QtApp-release-signed.apk"
		;;

	macos)
		echo "Configuring project for MacOS build..."
		echo "MACOS_QT_ROOT=${MACOS_QT_ROOT}"
		echo "_________________________________________________________________________"
		cmake ${PROJECT_DIR} \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_PREFIX_PATH=${MACOS_QT_ROOT} \
		;;

	"ios")
		echo "Configuring project for iOS build..."
		echo "IOS_QT_ROOT=${IOS_QT_ROOT}"
		echo "_________________________________________________________________________"
		cmake ${PROJECT_DIR} \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_PREFIX_PATH="${IOS_QT_ROOT}" \
			-DCMAKE_TOOLCHAIN_FILE="${PROJECT_DIR}/cmake/iOS/iOS.cmake" \
			-DLIBRARY_OUTPUT_PATH_ROOT="${BUILD_DIR}/LIBS"
		;;

esac

