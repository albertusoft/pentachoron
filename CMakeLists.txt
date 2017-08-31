project( pentachoron )
cmake_minimum_required( VERSION 2.8.11 )

set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/" )
set( CMAKE_INCLUDE_CURRENT_DIR ON )
set( CMAKE_AUTOMOC ON )

include(CMacros.cmake)


#############################################################################
#                         Packages / Libraries                              #
#############################################################################

find_package( Threads REQUIRED )

find_package( Qt5 COMPONENTS Core Gui Widgets Quick QuickWidgets Multimedia QuickControls2 3DQuick 3DQuickExtras 3DQuickRender 3DQuickInput 3DQuickAnimation Network Sensors Test Svg )
include( ${PROJECT_SOURCE_DIR}/cmake/Android/QtAndroid.cmake ) # include just after 'find_package(Qt5)'

if ( ANDROID )
	set( PLATFORM_LIBS android log ${CMAKE_THREAD_LIBS_INIT} )
else()
	set( PLATFORM_LIBS udev ${CMAKE_THREAD_LIBS_INIT} )
endif()

find_package( Threads REQUIRED )


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

function( find_sources _var_name _source_dir_and_filter )
	if ( "${ARGN}" STREQUAL "NONRECURSIVE" )
		set( _globbig GLOB )
	else()
		set( _globbig GLOB_RECURSE )
	endif()
	file( ${_globbig} _collected_files RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/${_source_dir_and_filter}" )
	set( ${_var_name} ${_collected_files} ${${_var_name}} PARENT_SCOPE )
endfunction()

# pentachoron application
find_sources( pentachoron_SRCS "src/*.cpp" )
find_sources( pentachoron_SRCS "src/*.qml" )
set( pentachoron_RESOURCES src/pentachoron.qrc )
android_custom_sources( pentachoron "${CMAKE_CURRENT_SOURCE_DIR}/android" )
qt5_add_resources( pentachoron_RESOURCES_CXX ${pentachoron_RESOURCES} )


#############################################################################
#                                TARGETS                                    #
#############################################################################

set( APP_LIBRARIES
	${PLATFORM_LIBS}
	Qt5::Gui Qt5::Quick Qt5::QuickWidgets Qt5::QuickControls2 Qt5::Multimedia Qt5::3DQuick Qt5::3DQuickExtras Qt5::3DQuickRender Qt5::3DQuickInput Qt5::3DQuickAnimation Qt5::Network Qt5::Sensors Qt5::Test Qt5::Svg
)

# pentachoron application
program_link_libraries_preset( pentachoron ${APP_LIBRARIES} )
add_program( pentachoron ${pentachoron_SRCS} ${pentachoron_RESOURCES_CXX} )
program_link_libraries( pentachoron )

# other targets to achive android build stages
set( ANDROID_BUILD_DIR ${CMAKE_SOURCE_DIR}/build/android-release )

# TODO HERE: create useabel targets
add_custom_target( App_BuildAndroidBinary COMMAND ${CMAKE_MAKE_PROGRAM} -C ${ANDROID_BUILD_DIR} WORKING_DIRECTORY ${ANDROID_BUILD_DIR} )
add_custom_target( App_BuildAndroidClean COMMAND ${CMAKE_MAKE_PROGRAM} -C ${ANDROID_BUILD_DIR} clean )
add_custom_target( App_PentachoronBuildAPK COMMAND ${CMAKE_MAKE_PROGRAM} -C ${ANDROID_BUILD_DIR} pentachoron_build_apk )
add_custom_target( App_PentachoronInstallAPK COMMAND ant installd WORKING_DIRECTORY ${ANDROID_BUILD_DIR}/APP/pentachoron )
