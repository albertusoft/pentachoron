project( pentachoron )
cmake_minimum_required( VERSION 2.8.11 )

set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/" )
set( CMAKE_INCLUDE_CURRENT_DIR ON )
set( CMAKE_AUTOMOC ON )

include(CMacros.cmake)

# load settings into variables
load_settingsfile( "${CMAKE_CURRENT_SOURCE_DIR}/app.conf" )
load_settingsfile( "${CMAKE_CURRENT_SOURCE_DIR}/local.conf" )

#############################################################################
#                         Packages / Libraries                              #
#############################################################################

set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE NEVER )

find_package( Threads REQUIRED )

find_package( Qt5 COMPONENTS Core Gui Widgets Quick QuickWidgets Multimedia QuickControls2 3DQuick 3DQuickExtras 3DQuickRender 3DQuickInput 3DQuickAnimation Network Sensors Test Svg )
include( ${PROJECT_SOURCE_DIR}/cmake/Android/QtAndroid.cmake ) # include just after 'find_package(Qt5)'

if ( ANDROID )
	find_package( Threads REQUIRED )
	set( PLATFORM_LIBS android log ${CMAKE_THREAD_LIBS_INIT} )
elseif( IOS )
	set( GUI_TYPE MACOSX_BUNDLE )
	find_library( CoreFoundation CoreFoundation )
	find_library( Foundation Foundation )
	find_library( Security Security )
	find_library( ExternalAccessory ExternalAccessory )
	find_library( CoreGraphics CoreGraphics )
	find_library( CoreText CoreText )
	find_library( MobileCoreServices MobileCoreServices )
	find_library( OpenGLES OpenGLES )
	find_library( UIKit UIKit )
	find_library( ImageIO ImageIO )
	find_library( z z )
	find_library( qtlibpng qtlibpng )
	find_library( qtharfbuzz qtharfbuzz )
	find_library( qtpcre2 qtpcre2 )
	find_library( qtfreetype qtfreetype )
	set( PLATFORM_LIBS ${CoreFoundation} ${Foundation} ${Security} ${ExternalAccessory} ${CoreGraphics} ${CoreText} ${OpenGLES} ${UIKit} ${ImageIO} ${MobileCoreServices} ${z} ${qtlibpng} ${qtharfbuzz} ${qtpcre2} ${qtfreetype} )
elseif( LINUX )
	find_package( Threads REQUIRED )
	set( PLATFORM_LIBS udev ${CMAKE_THREAD_LIBS_INIT} )
elseif( WIN32 )
	find_package( Threads REQUIRED )
	set( PLATFORM_LIBS ${CMAKE_THREAD_LIBS_INIT} )
	set( GUI_TYPE WIN32 )
elseif( APPLE )
	find_package( Threads REQUIRED )
	set( PLATFORM_LIBS ${CMAKE_THREAD_LIBS_INIT} )
	set( GUI_TYPE MACOSX_BUNDLE )
else()
	find_package( Threads REQUIRED )
	set( PLATFORM_LIBS ${CMAKE_THREAD_LIBS_INIT} )
endif()


#############################################################################
#                          Compile Environment                              #
#############################################################################

add_definitions( -Wall -Wno-unused )

set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions -funwind-tables -fPIC -std=c++11" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fexceptions -funwind-tables -fPIC" )

include_directories(
	src
)

set( Qt5_LIB_INCLUDE_DIRS
	${Qt5Core_INCLUDE_DIRS}
	${Qt5Quick_INCLUDE_DIRS}
	${Qt5QuickWidgets_INCLUDE_DIRS}
	${Qt5QuickControls2_INCLUDE_DIRS}
	${Qt5Multimedia_INCLUDE_DIRS}
	${Qt5Network_INCLUDE_DIRS}
	${Qt5Sensors_INCLUDE_DIRS}
	${Qt5Svg_INCLUDE_DIRS}
	${Qt5Test_INCLUDE_DIRS}
)


#############################################################################
#                                 OPTIONS                                   #
#############################################################################


#############################################################################
#                                SOURCES                                    #
#############################################################################

# pentachoron application
find_sources( pentachoron_SRCS "src/*.cpp" )
find_sources( pentachoron_SRCS "src/*.qml" )
set( pentachoron_RESOURCES src/pentachoron.qrc )
set( pentachoron_RC_FILE src/pentachoron.rc )
android_custom_sources( pentachoron "${CMAKE_CURRENT_SOURCE_DIR}/android" )
qt5_add_resources( pentachoron_RESOURCES_CXX ${pentachoron_RESOURCES} )


#############################################################################
#                                TARGETS                                    #
#############################################################################

set( APP_LIBRARIES
	${PLATFORM_LIBS}
	Qt5::Gui Qt5::Quick Qt5::QuickWidgets Qt5::QuickControls2 Qt5::Multimedia Qt5::3DQuick Qt5::3DQuickExtras Qt5::3DQuickRender Qt5::3DQuickInput Qt5::3DQuickAnimation Qt5::Network Qt5::Sensors Qt5::Test Qt5::Svg
)

# Icons
if(WIN32)
	add_rc_file( pentachoron )
elseif( APPLE )
	add_macosx_icon_file( pentachoron "${CMAKE_CURRENT_SOURCE_DIR}/resources/icons/pentachoron.icns" )
endif()

# pentachoron application
program_link_libraries_preset( pentachoron ${APP_LIBRARIES} )
add_program( pentachoron ${GUI_TYPE} ${pentachoron_SRCS} ${pentachoron_RESOURCES_CXX} )
program_link_libraries( pentachoron )

# other targets to achive android build stages
set( ANDROID_BUILD_DIR ${CMAKE_SOURCE_DIR}/build/android-release )

# installer
add_installer_target( installer pentachoron )

# TODO HERE: create target shortcuts
add_custom_target( App_BuildAndroidBinary COMMAND ${CMAKE_MAKE_PROGRAM} -C ${ANDROID_BUILD_DIR} WORKING_DIRECTORY ${ANDROID_BUILD_DIR} )
add_custom_target( App_BuildAndroidClean COMMAND ${CMAKE_MAKE_PROGRAM} -C ${ANDROID_BUILD_DIR} clean )
add_custom_target( App_PentachoronBuildAPK COMMAND ${CMAKE_MAKE_PROGRAM} -C ${ANDROID_BUILD_DIR} pentachoron_build_apk )
add_custom_target( App_PentachoronInstallAPK COMMAND ant installd WORKING_DIRECTORY ${ANDROID_BUILD_DIR}/APP/pentachoron )
