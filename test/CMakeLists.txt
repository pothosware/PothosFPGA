########################################################################
# Test stuff
########################################################################
include(GHDLUtil)

if (NOT GHDL_EXECUTABLE)
    message(WARNING "cant find ghdl executable, skipping...")
    return()
endif ()

add_library(myfuncs myfuncs.c)

GHDL_ELABORATE(
    TARGET testbench
    SOURCES
        demux.vhdl
        demux_tb.vhdl
    LIBRARIES m
)

GHDL_ELABORATE(
    TARGET mytest_tb
    SOURCES
        mytest_tb.vhdl
    LIBRARIES myfuncs
)
