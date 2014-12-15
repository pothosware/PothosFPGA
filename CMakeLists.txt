########################################################################
## Top level build project for host API and framework blocks
########################################################################
cmake_minimum_required(VERSION 2.8)
project(PothosFpgaTest)
enable_language(CXX C)
enable_testing()

find_package(Pothos CONFIG REQUIRED)

########################################################################
## Locate the GHDL simulation tool
########################################################################
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
include(GHDLUtil)

if (NOT GHDL_EXECUTABLE)
    message(WARNING "cant find ghdl executable")
    message(STATUS "GHDL used for rtl check and sim tests")
endif ()

if (GHDL_EXECUTABLE)
    add_subdirectory(rtl)
    add_subdirectory(sim)
endif (GHDL_EXECUTABLE)

########################################################################
## build subdirectories
########################################################################
add_subdirectory(blocks)
