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
## WORKING_DIRECTORY - output directory or CMAKE_CURRENT_BINARY_DIR
##
## STD - langage standard of VHDL (default "02" for VHDL2002)
########################################################################
function(GHDL_ELABORATE)

    include(CMakeParseArguments)
    CMAKE_PARSE_ARGUMENTS(GHDL "" "TARGET;WORKING_DIRECTORY;STD" "SOURCES;LIBRARIES" ${ARGN})

    #determine working directory
    if (NOT GHDL_WORKING_DIRECTORY)
        set(GHDL_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    endif ()

    #determine standard
    if (NOT GHDL_STD)
        set(GHDL_STD "02")
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
    foreach(file ${GHDL_SOURCES})
        get_filename_component(outfile ${file} NAME_WE)
        set(outfile "${CMAKE_CURRENT_BINARY_DIR}/${outfile}.o")
        list(APPEND outfiles ${outfile})
    endforeach(file)

    #analyze all the input files
    add_custom_command(
        OUTPUT ${outfiles}
        DEPENDS ${GHDL_SOURCES}
        COMMAND ${GHDL_EXECUTABLE} -a --std=${GHDL_STD} ${GHDL_SOURCES}
        WORKING_DIRECTORY ${GHDL_WORKING_DIRECTORY}
    )

    #generate linker arguments
    unset(elabdeps)
    unset(elabargs)
    foreach(lib ${GHDL_LIBRARIES})
        get_target_property(liblocation ${lib} LOCATION_${CMAKE_BUILD_TYPE})
        #is this an in-tree library?
        #save dependency list and library path
        if (liblocation)
            list(APPEND elabdeps ${lib})
            get_filename_component(libpath ${liblocation} PATH)
            list(APPEND elabargs "-Wl,-L${libpath}")
        endif ()
        #add the library to the linker
        list(APPEND elabargs "-Wl,-l${lib}")
    endforeach(lib)

    #elaborate - creates simulation exe
    list(INSERT elabargs 0 "-e")
    list(APPEND elabargs "${GHDL_TARGET}")
    string(TOLOWER ${GHDL_TARGET} targetlower)
    set(elaborated_output ${CMAKE_CURRENT_BINARY_DIR}/${targetlower})
    add_custom_command(
        OUTPUT ${elaborated_output}
        DEPENDS ${outfiles} ${elabdeps}
        COMMAND ${GHDL_EXECUTABLE}
        ARGS ${elabargs}
        WORKING_DIRECTORY ${GHDL_WORKING_DIRECTORY}
    )

    #build target for output executable
    add_custom_target(${GHDL_TARGET} ALL DEPENDS ${elaborated_output})

    set(__${GHDL_TARGET}_elaborated_output "${elaborated_output}" PARENT_SCOPE)

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
        FILES ${__${GHDL_TARGET}_elaborated_output}
        DESTINATION ${GHDL_DESTINATION}
    )

endfunction(GHDL_INSTALL)
