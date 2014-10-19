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
    message(FATAL_ERROR "cant find ghdl executable")
endif ()

########################################################################
## build subdirectories
########################################################################
add_subdirectory(lib)
add_subdirectory(test)
