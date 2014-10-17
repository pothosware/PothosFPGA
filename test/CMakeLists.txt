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
        ${CMAKE_CURRENT_SOURCE_DIR}/demux.vhdl
        ${CMAKE_CURRENT_SOURCE_DIR}/demux_tb.vhdl
)
