########################################################################
# Test stuff
########################################################################
include(GHDLUtil)

if (NOT GHDL_EXECUTABLE)
    message(WARNING "cant find ghdl executable, skipping...")
    return()
endif ()

add_library(PothosFPGA SHARED PothosFPGA.cpp)

GHDL_ELABORATE(
    TARGET mytest_tb
    SOURCES
        ExternalOutput.vhdl
        ExternalInput.vhdl
        mytest_tb.vhdl
    LIBRARIES PothosFPGA
)
