########################################################################
## Build the PothosInterconnect library
########################################################################
GHDL_ELABORATE(
    TARGET PothosInterconnect
    LIBRARY PothosInterconnect
    SOURCES
        extras/sizing.vhdl
        extras/synchronizing.vhdl
        extras/memory.vhdl
        extras/fifos.vhdl
        InterconnectPkg.vhdl
        StreamFifo.vhdl
        StreamInspector.vhdl
        StreamCombiner.vhdl
        StreamSplitter.vhdl
        StreamValve.vhdl
        LaneOutgress.vhdl
        LaneIngress.vhdl
        Interconnect.vhdl
    IEEE synopsys
    ANALYZE_ONLY
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)
