########################################################################
## Top level build project for host API and framework blocks
########################################################################
cmake_minimum_required(VERSION 2.8)
project(PothosFpgaTest)
enable_language(CXX C)
enable_testing()

find_package(Pothos CONFIG REQUIRED)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
add_subdirectory(test)
