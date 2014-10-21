if(DEFINED INCLUDED_GHDL_UTIL_CMAKE)
    return()
endif()
set(INCLUDED_GHDL_UTIL_CMAKE TRUE)

########################################################################
## GHDL Util - utility methods for working with GHDL compiler
##
## Defines:
## GHDL_EXECUTABLE - defined when GHDL is found
## GHDL_ELABORATE() - utility function to build simulations
## GHDL_INSTALL() - install simulation executables
########################################################################

find_program(GHDL_EXECUTABLE ghdl)
message(STATUS "GHDL_EXECUTABLE: ${GHDL_EXECUTABLE}")
if (NOT GHDL_EXECUTABLE)
    return()
endif ()

########################################################################
## GHDL_ELABORATE - build simulations from vhdl sources.
##
## Elaborate VHDL design units to produce a simulation executable.
##
## Arguments:
##
## TARGET - the name of the top level testbench
## an executable will be produced with the same name
##
## SOURCES - a list of vhdl source files to analyze
##
## LIBRARIES - a list of libraries to link against
##
## DEPENDS - other analyzed targets required by this target
##
## WORKING_DIRECTORY - output directory or CMAKE_CURRENT_BINARY_DIR
##
## STD - langage standard of VHDL
##
## LIBRARY - Specify the name of the WORK library
##
## IEEE - Select the IEEE library to use
##
## ANALYZE_ONLY - set this to check the sources
## No test bench required, elaboration will not be performed.
########################################################################
function(GHDL_ELABORATE)

    include(CMakeParseArguments)
    CMAKE_PARSE_ARGUMENTS(GHDL "ANALYZE_ONLY" "TARGET;WORKING_DIRECTORY;STD;LIBRARY;IEEE" "SOURCES;LIBRARIES;DEPENDS" ${ARGN})

    #determine working directory
    if (NOT GHDL_WORKING_DIRECTORY)
        set(GHDL_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    endif ()

    #determine standard
    if (GHDL_STD)
        set(GHDL_STD "--std=${GHDL_STD}")
    endif ()

    #determine ieee
    if (GHDL_IEEE)
        set(GHDL_IEEE "--ieee=${GHDL_IEEE}")
    endif ()

    #determine library
    if (NOT GHDL_LIBRARY)
        set(GHDL_LIBRARY "work")
    endif ()

    #turn sources into an absolute path
    unset(__sources)
    foreach(source ${GHDL_SOURCES})
        if (EXISTS ${source})
            list(APPEND __sources ${source})
        else()
            list(APPEND __sources ${CMAKE_CURRENT_SOURCE_DIR}/${source})
        endif()
    endforeach(source)
    set(GHDL_SOURCES ${__sources})

    #generate a list of output files
    unset(outfiles)
    unset(outnames)
    foreach(file ${GHDL_SOURCES})
        get_filename_component(outfile ${file} NAME_WE)
        set(outnames "${outnames}${outfile}.o, ")
        set(outfile "${GHDL_WORKING_DIRECTORY}/${outfile}.o")
        list(APPEND outfiles ${outfile})
    endforeach(file)

    #the analyzed output file
    string(TOLOWER ${GHDL_LIBRARY} librarylower)
    set(analyzed_output "${GHDL_WORKING_DIRECTORY}/${librarylower}-obj93.cf")
    set(__${GHDL_TARGET}_analyzed_output "${analyzed_output}" CACHE STRING "" FORCE)

    #analyze all the input files
    add_custom_command(
        OUTPUT ${analyzed_output} ${outfiles}
        DEPENDS ${GHDL_SOURCES} ${GHDL_DEPENDS}
        COMMAND ${GHDL_EXECUTABLE} -a ${GHDL_STD} ${GHDL_IEEE} --work=${GHDL_LIBRARY} ${GHDL_SOURCES}
        WORKING_DIRECTORY ${GHDL_WORKING_DIRECTORY}
        COMMENT "Analysis ${GHDL_WORKING_DIRECTORY}/${outnames}"
    )

    #handle analyze only
    if (GHDL_ANALYZE_ONLY)
        add_custom_target(${GHDL_TARGET} ALL DEPENDS ${analyzed_output})
        return()
    endif ()

    #determine library dependencies and linker arguments
    unset(libdeps)
    unset(linkargs)
    foreach(lib ${GHDL_LIBRARIES})
        get_target_property(liblocation ${lib} LOCATION_${CMAKE_BUILD_TYPE})
        get_filename_component(ext ${lib} EXT)
        #is this an in-tree library?
        #save dependency list and library path
        #and add the library to the linker
        if (liblocation)
            list(APPEND libdeps ${lib})
            list(APPEND linkargs "-Wl,-l:${liblocation}")
        elseif (ext)
            list(APPEND linkargs "-Wl,-l:${lib}")
        else ()
            list(APPEND linkargs "-Wl,-l${lib}")
        endif ()
    endforeach(lib)

    #elaborate - creates simulation exe
    string(TOLOWER ${GHDL_TARGET} targetlower)
    set(elaborated_output_obj "${GHDL_WORKING_DIRECTORY}/e~${targetlower}.o")
    set(elaborated_output "${GHDL_WORKING_DIRECTORY}/${targetlower}")
    add_custom_command(
        OUTPUT ${elaborated_output} ${elaborated_output_obj}
        DEPENDS ${analyzed_output} ${libdeps}
        COMMAND ${GHDL_EXECUTABLE} -e ${GHDL_IEEE} --work=${GHDL_LIBRARY} ${linkargs} ${GHDL_TARGET}
        WORKING_DIRECTORY ${GHDL_WORKING_DIRECTORY}
        COMMENT "Elaboration ${elaborated_output}"
    )

    #build target for output executable
    add_custom_target(${GHDL_TARGET} ALL DEPENDS ${elaborated_output})

    set(__${GHDL_TARGET}_elaborated_output "${elaborated_output}" CACHE STRING "" FORCE)

endfunction(GHDL_ELABORATE)

########################################################################
## GHDL_INSTALL - install simulation executable.
##
## Arguments:
##
## TARGET - the name of the top level testbench
##
## DESTINATION - installation destination
########################################################################
function(GHDL_INSTALL)

    include(CMakeParseArguments)
    CMAKE_PARSE_ARGUMENTS(GHDL "" "TARGET;DESTINATION" "" ${ARGN})

    install(
        PROGRAMS ${__${GHDL_TARGET}_elaborated_output}
        DESTINATION ${GHDL_DESTINATION}
    )

endfunction(GHDL_INSTALL)
