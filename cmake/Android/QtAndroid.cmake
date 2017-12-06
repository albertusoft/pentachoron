#############################################################################################################################################
#############################################################################################################################################

if ( NOT ANDROID )

	function( add_program _target_NAME )
		add_executable( ${_target_NAME} ${ARGN} )
	endfunction()

	function( android_custom_sources _targetName _dirName )
		# NOOP
	endfunction()

	function( program_link_libraries_preset _targetName )
		set( PROGRAM_LINK_LIBRARIES_VAR_${_targetName} ${ARGN} PARENT_SCOPE )
	endfunction()

	function( program_link_libraries _targetName )
		target_link_libraries( ${_targetName} ${PROGRAM_LINK_LIBRARIES_VAR_${_targetName}} )
	endfunction()

	return()

endif()

#############################################################################################################################################
#############################################################################################################################################

set( ANDROID_DEPLOY_QT_DEPLOYMENT "bundled" ) # ["bundled","ministro","debug"]

if ( ANDROID_NDK_ABI_NAME STREQUAL armeabi-v7a OR ANDROID_NDK_ABI_NAME STREQUAL armeabi )
	set(ANDROID_SYSROOT_ARCH arch-arm)
else()
	set(ANDROID_SYSROOT_ARCH arch-${ANDROID_NDK_ABI_NAME})
endif()

## these lines should go to Qt5CoreConfigExtras.cmake next to moc, rcc, etc.
if ( NOT TARGET Qt5::androiddeployqt )
	add_executable(Qt5::androiddeployqt IMPORTED)

	set(imported_location "${_qt5Core_install_prefix}/bin/androiddeployqt")
	_qt5_Core_check_file_exists(${imported_location})

	set_target_properties(Qt5::androiddeployqt PROPERTIES IMPORTED_LOCATION ${imported_location} )

	# For CMake automoc feature
	get_target_property(QT_ANDROIDDEPLOYQT_EXECUTABLE Qt5::androiddeployqt LOCATION)
endif()
## these lines should go to Qt5CoreConfigExtras.cmake next to moc, rcc, etc.

function( get_target_fullpath _variableName _target_NAME )
	cmake_policy(PUSH)
	if ( ${CMAKE_MAJOR_VERSION} EQUAL "3" )
		cmake_policy( SET CMP0026 OLD )
	endif()
	get_target_property( _var ${_target_NAME} LOCATION )
	set( ${_variableName} ${_var} PARENT_SCOPE )
	cmake_policy(POP)
endfunction()

#############################################################################################################################################
#############################################################################################################################################

macro( android_custom_sources _targetName _dirName )
	set( ANDROID_CUSTOM_SOURCES_DIRS_${_targetName} ${ANDROID_CUSTOM_SOURCES_DIRS_${_targetName}} ${_dirName} )
endmacro()

function( program_link_libraries_preset _targetName )
	set( _libList )
	foreach( _libItem ${ARGN} )
		if ( TARGET ${_libItem} )
			get_target_fullpath( _libFullItem ${_libItem} )
			message( STATUS "LIB: ${_libItem} => ${_libFullItem}" )
		else()
			message( STATUS "LIB: ${_libItem}" )
			set( _libFullItem ${_libItem} )
		endif()
		set( _libList ${_libList} ${_libFullItem} )
	endforeach()
	set( PROGRAM_LINK_LIBRARIES_VAR_${_targetName} ${ARGN} PARENT_SCOPE )
	set( ANDROID_APPLICATION_LIBRARIES_FULLPATHS_${_targetName} ${_libList} PARENT_SCOPE )
endfunction()

function( program_link_libraries _targetName )
	target_link_libraries( ${_targetName} ${PROGRAM_LINK_LIBRARIES_VAR_${_targetName}} )
endfunction()

macro( add_program _targetName )

	# add application main library (a native program should exists as a library file in Androd system)
	add_library( ${_targetName} SHARED ${ARGN} )

	# set varaibles
	set( CMAKE_ANDROID_BUILD_FOLDER ${CMAKE_CURRENT_BINARY_DIR}/APP/${_targetName} )
	set( CMAKE_ANDROID_NATIVE_LIBS_FOLDER ${CMAKE_ANDROID_BUILD_FOLDER}/libs/${ANDROID_NDK_ABI_NAME} )
	set( ANDROID_TARGET_NAME ${_targetName} )
	get_target_fullpath( ANDROID_APPLICATION_BINARY_FULLPATH ${_targetName} )
	set( ANDROID_APPLICATION_LIBRARIES_FULLPATHS ${ANDROID_APPLICATION_LIBRARIES_FULLPATHS_${_targetName}} ) # <---- TODO: put linked libraries here
	set( ANDROID_CUSTOM_SOURCES_DIRS ${ANDROID_CUSTOM_SOURCES_DIRS_${_targetName}} )
	set( ANDROID_CUSTOM_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/APP/${_targetName}_customsrc )
#	if( CMAKE_BUILD_TYPE MATCHES "Release" )
#		set( ANDROID_DEPLOY_QT_RELEASE ON )
#		message( STATUS "ANDROID_DEPLOY_QT_RELEASE=ON" )
#	endif()

	## Copy the android templates from qt install folder
	## This line it should be in qt cmake files
	message( STATUS "AndroidSrc=${_qt5Core_install_prefix}/src/android/java" )
	file(	COPY "${_qt5Core_install_prefix}/src/android/java"
		DESTINATION "${CMAKE_ANDROID_BUILD_FOLDER}"
		FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
		DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
	)

	# create a cmake file in build directory which intented to construct android package
	configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Android/QtAndroid_BuildAPK.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/QtAndroid_BuildAPK_${_targetName}.cmake @ONLY )

	# add build APK package rule
	add_custom_target( ${_targetName}_build_apk
		COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/QtAndroid_BuildAPK_${_targetName}.cmake
		DEPENDS ${_targetName}
	)

endmacro()
