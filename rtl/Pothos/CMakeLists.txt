########################################################################
## Build the PothosInterconnect library
########################################################################
GHDL_ELABORATE(
    TARGET PothosInterconnect
    LIBRARY PothosInterconnect
    SOURCES
        Interconnect.vhdl
        StreamFifo.vhdl
        StreamCombiner.vhdl
        StreamSplitter.vhdl
    DEPENDS vhdl-extras
    ANALYZE_ONLY
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)
