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
        pothos_axi_interconnect.vhdl
    IEEE synopsys
    ANALYZE_ONLY
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
)

########################################################################
# generated wrappers
########################################################################
find_package(PythonInterp)

set(gen_tmpl_py ${CMAKE_CURRENT_SOURCE_DIR}/generate_tmpl.py)

if(GEN_ENABLED AND PYTHON_EXECUTABLE)
    add_custom_command(
        OUTPUT
            ${CMAKE_CURRENT_SOURCE_DIR}/pothos_axi_interconnect.vhdl
        DEPENDS
            ${CMAKE_CURRENT_SOURCE_DIR}/pothos_axi_interconnect.vhdl.tmpl
            ${gen_tmpl_py}
        COMMAND ${PYTHON_EXECUTABLE} ${gen_tmpl_py}
            ${CMAKE_CURRENT_SOURCE_DIR}/pothos_axi_interconnect.vhdl.tmpl
            ${CMAKE_CURRENT_SOURCE_DIR}/pothos_axi_interconnect.vhdl
    )
    add_custom_target(gen_axi_wrapper ALL DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/pothos_axi_interconnect.vhdl)
endif()
