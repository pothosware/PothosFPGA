########################################################################
## Build the vhdl extras library
########################################################################
GHDL_ELABORATE(
    TARGET vhdl-extras
    LIBRARY extras
    SOURCES
        sizing.vhdl
        synchronizing.vhdl
        memory.vhdl
        fifos.vhdl
    IEEE synopsys
    ANALYZE_ONLY
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)
