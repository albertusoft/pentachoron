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


function( generate_installer_target _Target )

	get_property( _ExePath TARGET ${_Target} PROPERTY LOCATION )
	get_filename_component( _ExeName ${_ExePath} NAME )

	set( APP_PACKAGE_DIR "${CMAKE_CURRENT_BINARY_DIR}/PACKAGE" )
	set( APP_PACKAGE_COMPONENT_DIR "${APP_PACKAGE_DIR}/packages/${APP_NAMESPACE}" )
	set( APP_DEPLOYMENT_DIR "${CMAKE_CURRENT_BINARY_DIR}/DEPLOYMENT" )

	# deploy files
	if( UNIX AND NOT APPLE )
		set ( PROG_DEPLOYQT "${LINUX_QT_INSTALLER_PATH}/bin/linuxdeployqt" )
		set ( PROG_DEPLOYQT_ARGS "${APP_DEPLOYMENT_DIR}/${_ExeName}" -qmldir="${CMAKE_CURRENT_SOURCE_DIR}/src" -appimage )
		set ( PROG_ARCHIVEGEN "${LINUX_QT_INSTALLER_PATH}/bin/archivegen" )
		set ( PROG_BINARYCREATOR "${LINUX_QT_INSTALLER_PATH}/bin/binarycreator" )
		set ( APP_INSTALLER_NAME "${APP_NAME}-installer.bin" )
	elseif( WIN32 )
		set ( PROG_DEPLOYQT "${WIN32_QT_ROOT}/bin/windeployqt.exe" )
		set ( PROG_DEPLOYQT_ARGS --release --qmldir "${CMAKE_CURRENT_SOURCE_DIR}/src" "${APP_DEPLOYMENT_DIR}/${_ExeName}" )
		set ( PROG_ARCHIVEGEN "${WIN32_QT_INSTALLER_PATH}/bin/archivegen.exe" )
		set ( PROG_BINARYCREATOR "${WIN32_QT_INSTALLER_PATH}/bin/binarycreator.exe" )
		set ( APP_INSTALLER_NAME "${APP_NAME}-installer.exe" )
	elseif( APPLE )
		set ( PROG_DEPLOYQT "${MACOS_QT_ROOT}/bin/macdeployqt" )
		set ( PROG_DEPLOYQT_ARGS "${APP_DEPLOYMENT_DIR}/${_ExeName}" -qmldir="${CMAKE_CURRENT_SOURCE_DIR}/src" -dmg )
		set ( PROG_ARCHIVEGEN "archivegen" )
		set ( PROG_BINARYCREATOR "binarycreator" )
		set ( APP_INSTALLER_NAME "${APP_NAME}-installer.dmg" )
	endif()

	if ( APP_INSTALLER_NAME )
		message( STATUS "Creating installer generator target for: ${_ExePath}" )
		prepare_installer()
		add_custom_target( App_${_Target}_GenInstaller
			COMMAND ${CMAKE_COMMAND} -E copy ${_ExePath} "${APP_DEPLOYMENT_DIR}"
			COMMAND ${PROG_DEPLOYQT} ${PROG_DEPLOYQT_ARGS}
			COMMAND ${PROG_ARCHIVEGEN} "${APP_PACKAGE_COMPONENT_DIR}/data/main.7z" "${APP_DEPLOYMENT_DIR}/*"
			COMMAND ${PROG_BINARYCREATOR}
				-c "${APP_PACKAGE_DIR}/config/config.xml"
				-p "${APP_PACKAGE_DIR}/packages"
				"${CMAKE_CURRENT_BINARY_DIR}/INSTALLER/${APP_INSTALLER_NAME}"
		)
	endif()

endfunction()


function( update_androidmainfest_versionnums )
	execute_process( COMMAND ${GIT_EXECUTABLE} rev-list --count HEAD OUTPUT_VARIABLE APP_REVISION_COUNT )
endfunction()

