########################################################################
# Test stuff
########################################################################
include(GHDLUtil)

if (NOT GHDL_EXECUTABLE)
    message(WARNING "cant find ghdl executable, skipping...")
    return()
endif ()

add_subdirectory(External)

GHDL_ELABORATE(
    TARGET mytest_tb
    SOURCES
        External/ExternalPkg.vhdl
        External/ExternalOutput.vhdl
        External/ExternalInput.vhdl
        mytest_tb.vhdl
    LIBRARIES PothosFPGA
)
