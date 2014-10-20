########################################################################
## Create VHDL interface with simulation server interface
########################################################################
include_directories(${Pothos_INCLUDE_DIRS})

add_library(PothosFPGAHarness SHARED
    SimulationHarness.cpp
    SimulationServer.cpp
)
target_link_libraries(PothosFPGAHarness ${Pothos_LIBRARIES})

install(TARGETS PothosFPGAHarness
    LIBRARY DESTINATION lib${LIB_SUFFIX} # .so file
    ARCHIVE DESTINATION lib${LIB_SUFFIX} # .lib file
    RUNTIME DESTINATION bin              # .dll file
)

########################################################################
## quick testbench for compiles -- replace w/ better later
########################################################################
GHDL_ELABORATE(
    TARGET SimpleLoopbackTb
    SOURCES
        SimulationHarnessPkg.vhdl
        ExternalSource.vhdl
        ExternalSink.vhdl
        SimpleLoopbackTb.vhdl
    LIBRARIES PothosFPGAHarness
)

GHDL_INSTALL(
    TARGET SimpleLoopbackTb
    DESTINATION lib${LIB_SUFFIX}/Pothos/fpga/test
)

########################################################################
## module for the unit test side of the test bench
########################################################################
POTHOS_MODULE_UTIL(
    TARGET SimpleLoopbackTest
    SOURCES SimpleLoopbackTest.cpp
    DESTINATION fpga
)
