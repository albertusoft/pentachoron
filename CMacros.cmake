#############################################################################
#                                                                           #
#                               [ MACROS ]                                  #
#                                                                           #
#############################################################################

find_package(Git)


function( find_sources _var_name _source_dir_and_filter )
	if ( "${ARGN}" STREQUAL "NONRECURSIVE" )
		set( _globbig GLOB )
	else()
		set( _globbig GLOB_RECURSE )
	endif()
	file( ${_globbig} _collected_files RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/${_source_dir_and_filter}" )
	set( ${_var_name} ${_collected_files} ${${_var_name}} PARENT_SCOPE )
endfunction()


macro( add_rc_file __basename )
	set( __RCFILE ${${__basename}_RC_FILE} )
	if(MINGW)
		# resource compilation for mingw
		add_custom_command(
			OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${__RCFILE}.o
			COMMAND windres.exe -I${CMAKE_CURRENT_SOURCE_DIR}
					-i${CMAKE_CURRENT_SOURCE_DIR}/${__RCFILE}
					-o ${CMAKE_CURRENT_BINARY_DIR}/${__RCFILE}.o)
		set( ${__basename}_SRCS ${${__basename}_SRCS} ${CMAKE_CURRENT_BINARY_DIR}/${__RCFILE}.o)
	else(MINGW)
		set( ${__basename}_SRCS ${${__basename}_SRCS} ${__RCFILE} )
	endif(MINGW)
endmacro()


macro( wrap_source_files __basename )
	
	# --- qt wrapper ---
	set(${__basename}_SRCS ${${__basename}_SRCS} ${${__basename}_HEADERS})
	set(${__basename}_SRCS ${${__basename}_SRCS} ${${__basename}_MOC_HEADERS})
	set(${__basename}_SRCS ${${__basename}_SRCS} ${${__basename}_UIs})
	qt5_wrap_ui(${__basename}_SRCS ${${__basename}_UIs})
	qt5_wrap_cpp(${__basename}_SRCS ${${__basename}_MOC_HEADERS})
	qt5_add_resources(${__basename}_SRCS ${${__basename}_RESOURCES})
	
endmacro()

macro( load_settingsfile _SettingsFileName )
	file( STRINGS ${_SettingsFileName} _LinesInFile )
	foreach( _Line ${_LinesInFile} )
		string( REGEX REPLACE "^[ ]+" "" _Line ${_Line} ) # remove leading spaces from the line
		string( REGEX MATCH "^[^=]+" _Key ${_Line} ) # extract key
		string( REPLACE "${_Key}=" "" _Value ${_Line} ) # extract value
		string( REGEX REPLACE "^[\"]+" "" _Value ${_Value} ) # remove leading quotes from value
		string( REGEX REPLACE "[\"]+$" "" _Value ${_Value} ) # remove ending quotes from value
		set( ${_Key} "${_Value}" )
	endforeach()
endmacro()

function( get_target_location_property _variableName _target_NAME )
	if ( ${CMAKE_MAJOR_VERSION} EQUAL "2" )
		#cmake_policy(PUSH)
		#cmake_policy( SET CMP0026 OLD )
		get_target_property( _var ${_target_NAME} LOCATION )
		set( ${_variableName} ${_var} PARENT_SCOPE )
		#cmake_policy(POP)
	else()
		set( ${_variableName} $<TARET_FILE:${_target_NAME}> PARENT_SCOPE )
	endif()
endfunction()

function( prepare_installer )

	message( STATUS "prepare installer" )

	# declare more varables
	set( APP_PACKAGE_DIR ${CMAKE_CURRENT_BINARY_DIR}/PACKAGE )
	set( APP_PACKAGE_COMPONENT_DIR ${APP_PACKAGE_DIR}/packages/${APP_NAMESPACE}/ )
	string( TIMESTAMP DATETIME "%Y-%m-%d" )
	set( APP_TARGETDIR "@ApplicationsDirX86@/${APP_NAME}" )

	set( APP__TargetDir__ "@TargetDir@" )
	set( APP__StartMenuDir__ "@StartMenuDir@" )
	set( APP__DesktopDir__ "@DesktopDir@" )

	if ( WIN32 )
		set( APP_TARGET_EXE "@TargetDir@/${APP_NAME}.exe" )
	else()
		set( APP_TARGET_EXE "@TargetDir@/${APP_NAME}" )
	endif()

	# create directories
	file( MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/DEPLOYMENT" )
	file( MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/INSTALLER" )
	file( MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/PACKAGE" )
	file( MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/PACKAGE/config" )
	file( MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/PACKAGE/packages" )
	file( MAKE_DIRECTORY "${APP_PACKAGE_COMPONENT_DIR}" )
	file( MAKE_DIRECTORY "${APP_PACKAGE_COMPONENT_DIR}/data" )
	file( MAKE_DIRECTORY "${APP_PACKAGE_COMPONENT_DIR}/meta" )

	# copy template files to final destination
	configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/${APP_LICENSE_FILE} ${APP_PACKAGE_COMPONENT_DIR}/meta COPYONLY )
	configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/scripts/templatefiles/config.xml ${APP_PACKAGE_DIR}/config @ONLY )
	configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/scripts/templatefiles/package.xml ${APP_PACKAGE_COMPONENT_DIR}/meta @ONLY )
	configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/scripts/templatefiles/installscript.qs ${APP_PACKAGE_COMPONENT_DIR}/meta @ONLY )

endfunction()


function( add_installer_target _InsallerTarget _AppTarget )

	get_target_location_property( _ExePath ${_AppTarget} )
	get_filename_component( _ExeName ${_ExePath} NAME )

	set( APP_PACKAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/PACKAGE" )
	set( APP_PACKAGE_COMPONENT_DIR "${APP_PACKAGE_DIR}/packages/${APP_NAMESPACE}" )
	set( APP_DEPLOYMENT_DIR "${CMAKE_CURRENT_BINARY_DIR}/DEPLOYMENT" )

	# deploy files
	if( UNIX AND NOT APPLE )		
		message( STATUS "Creating Linux installer generator target for: ${_ExePath}" )
		prepare_installer()
		add_custom_target( ${_InsallerTarget}
			COMMAND ${CMAKE_COMMAND} -E copy ${_ExePath} "${APP_DEPLOYMENT_DIR}"
			COMMAND "${LINUX_QT_INSTALLER_PATH}/bin/linuxdeployqt" "${APP_DEPLOYMENT_DIR}/${_ExeName}" -qmldir="${CMAKE_CURRENT_SOURCE_DIR}/src" -appimage
			COMMAND "${LINUX_QT_INSTALLER_PATH}/bin/archivegen" "${APP_PACKAGE_COMPONENT_DIR}/data/main.7z" "${APP_DEPLOYMENT_DIR}/*"
			COMMAND "${LINUX_QT_INSTALLER_PATH}/bin/binarycreator"
				-c "${APP_PACKAGE_DIR}/config/config.xml"
				-p "${APP_PACKAGE_DIR}/packages"
				"${CMAKE_CURRENT_BINARY_DIR}/INSTALLER/${APP_NAME}-installer.bin"
		)
	elseif( WIN32 )
		message( STATUS "Creating Win32 installer generator target for: ${_ExePath}" )
		prepare_installer()
		add_custom_target( ${_InsallerTarget}
			COMMAND ${CMAKE_COMMAND} -E copy ${_ExePath} "${APP_DEPLOYMENT_DIR}"
			COMMAND "${WIN32_QT_ROOT}/bin/windeployqt.exe" --release --qmldir "${CMAKE_CURRENT_SOURCE_DIR}/src" "${APP_DEPLOYMENT_DIR}/${_ExeName}"
			COMMAND "${WIN32_QT_INSTALLER_PATH}/bin/archivegen.exe" "${APP_PACKAGE_COMPONENT_DIR}/data/main.7z" "${APP_DEPLOYMENT_DIR}/*"
			COMMAND "${WIN32_QT_INSTALLER_PATH}/bin/binarycreator.exe"
				-c "${APP_PACKAGE_DIR}/config/config.xml"
				-p "${APP_PACKAGE_DIR}/packages"
				"${CMAKE_CURRENT_BINARY_DIR}/INSTALLER/${APP_NAME}-installer.exe"
		)
	elseif( APPLE )
		message( STATUS "Creating MacOS installer generator target for: ${_ExePath}" )
		set_target_properties( ${_AppTarget} PROPERTIES MACOSX_BUNDLE TRUE )
		get_target_property( _ExeBundleName ${_AppTarget} MACOSX_BUNDLE_BUNDLE_NAME )
		set( APP_BUNDLE_PATH "${CMAKE_CURRENT_BINARY_DIR}/${_ExeBundleName}" )
		message( STATUS "APP_BUNDLE_PATH=${APP_BUNDLE_PATH}" )
		configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/resources/icons/${_AppTarget}.icns ${APP_BUNDLE_PATH}/Contents/Resources COPYONLY )
		set_target_properties( ${_AppTarget} MACOSX_BUNDLE_ICON_FILE "${_AppTarget}.icns" )
		prepare_installer()
		add_custom_target( ${_InsallerTarget}
			COMMAND "${MACOS_QT_ROOT}/bin/macdeployqt" "${APP_BUNDLE_PATH}" -qmldir="${CMAKE_CURRENT_SOURCE_DIR}/src" -dmg
			#COMMAND "${MACOS_QT_INSTALLER_PATH}/bin/archivegen" "${APP_PACKAGE_COMPONENT_DIR}/data/main.7z" "${APP_DEPLOYMENT_DIR}/*"
			#COMMAND "${MACOS_QT_INSTALLER_PATH}/bin/binarycreator" -c "${APP_PACKAGE_DIR}/config/config.xml" -p "${APP_PACKAGE_DIR}/packages" "${CMAKE_CURRENT_BINARY_DIR}/INSTALLER/${APP_NAME}-installer"
		)
	endif()

endfunction()


function( update_androidmainfest_versionnums )
	execute_process( COMMAND ${GIT_EXECUTABLE} rev-list --count HEAD OUTPUT_VARIABLE APP_REVISION_COUNT )
endfunction()

