########################################################################
## Check the contents of the lib directory
########################################################################
GHDL_ELABORATE(
    TARGET PothosFPGALibs
    SOURCES Interconnect.vhdl
    ANALYZE_ONLY
)
