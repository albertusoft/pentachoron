#############################################################################
#                                                                           #
#                               [ MACROS ]                                  #
#                                                                           #
#############################################################################

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


