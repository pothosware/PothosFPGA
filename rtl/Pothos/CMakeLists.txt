########################################################################
## Build the PothosInterconnect library
########################################################################
GHDL_ELABORATE(
    TARGET PothosInterconnect
    LIBRARY PothosInterconnect
    SOURCES
        InterconnectPkg.vhdl
        StreamFifo.vhdl
        StreamInspector.vhdl
        StreamCombiner.vhdl
        StreamSplitter.vhdl
        StreamValve.vhdl
        LaneOutgress.vhdl
        LaneIngress.vhdl
        Interconnect.vhdl
    DEPENDS vhdl-extras
    ANALYZE_ONLY
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)
