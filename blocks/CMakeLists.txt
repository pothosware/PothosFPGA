########################################################################
## Build module for pothos fpga blocks
########################################################################

include_directories(${PROJECT_SOURCE_DIR}/kernel)

set(SOURCES
    ZynqDMASource.cpp
    ZynqDMASink.cpp
    ZynqBufferManager.cpp
)

POTHOS_MODULE_UTIL(
    TARGET FPGASupport
    SOURCES ${SOURCES}
    DESTINATION blocks/fpga
    ENABLE_DOCS
)
