########################################################################
# Test stuff
########################################################################
include(GHDLUtil)

if (NOT GHDL_EXECUTABLE)
    message(WARNING "cant find ghdl executable, skipping...")
    return()
endif ()

GHDL_ELABORATE(
    TARGET testbench
    SOURCES
        demux.vhdl
        demux_tb.vhdl
    LIBRARIES m
)
