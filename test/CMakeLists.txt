########################################################################
# Test stuff
########################################################################
include(GHDLUtil)

if (NOT GHDL_EXECUTABLE)
    message(WARNING "cant find ghdl executable, skipping...")
    return()
endif ()

########################################################################
## Create VHDL interface with simulation server interface
########################################################################
include_directories(${Pothos_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(PothosFPGA SHARED
    PothosFPGA.cpp
    SimulationServer.cpp
)
target_link_libraries(PothosFPGA ${Pothos_LIBRARIES})

########################################################################
## quick testbench for compiles -- replace w/ better later
########################################################################
GHDL_ELABORATE(
    TARGET mytest_tb
    SOURCES
        ExternalSource.vhdl
        ExternalSink.vhdl
        mytest_tb.vhdl
    LIBRARIES PothosFPGA
)
