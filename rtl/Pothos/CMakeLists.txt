########################################################################
## Build the PothosInterconnect library
########################################################################
GHDL_ELABORATE(
    TARGET PothosInterconnect
    LIBRARY PothosInterconnect
    SOURCES
        StreamFifo.vhdl
        StreamInspector.vhdl
        StreamCombiner.vhdl
        StreamSplitter.vhdl
        Interconnect.vhdl
    DEPENDS vhdl-extras
    ANALYZE_ONLY
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)
