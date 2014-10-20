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
## Create VHDL library for external simulation interface
########################################################################
GHDL_ELABORATE(
    TARGET PothosSimulation
    LIBRARY PothosSimulation
    SOURCES
        ExternalFunctionsPkg.vhdl
        ExternalSource.vhdl
        ExternalSink.vhdl
    ANALYZE_ONLY
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)

########################################################################
## simple loopback testbench
########################################################################
GHDL_ELABORATE(
    TARGET SimpleLoopbackTb
    LIBRARY SimpleLoopbackTb
    SOURCES SimpleLoopbackTb.vhdl
    LIBRARIES
        PothosSimulation
        PothosFPGAHarness
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)

GHDL_INSTALL(
    TARGET SimpleLoopbackTb
    DESTINATION lib${LIB_SUFFIX}/Pothos/fpga/test
)

########################################################################
## fifo loopback testbench
########################################################################
GHDL_ELABORATE(
    TARGET FifoLoopbackTb
    LIBRARY FifoLoopbackTb
    SOURCES FifoLoopbackTb.vhdl
    LIBRARIES
        PothosInterconnect
        PothosSimulation
        PothosFPGAHarness
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    IEEE synopsys
)

GHDL_INSTALL(
    TARGET FifoLoopbackTb
    DESTINATION lib${LIB_SUFFIX}/Pothos/fpga/test
)

########################################################################
## build and install unit tests
########################################################################
POTHOS_MODULE_UTIL(
    TARGET SimulationUnitTests
    SOURCES
        SimulationClient.cpp
        SimpleLoopbackTest.cpp
    DESTINATION fpga
)
