/***********************************************************************
 * AXI DMA v7.1 userspace driver for Scatter/Gather mode
 **********************************************************************/

#include <stddef.h>
#include <stdint.h>

//! Forward declare DMA descriptor
struct xilinx_dma_desc_sg;

//! User DMA state and configuration structure
typedef struct
{
    //! configuration variables: set by user at init

    size_t hardware_register_base; //!< Hardware address for start of DMA registers
    size_t hardware_shared_base; //!< Hardware address for start of shared memory
    size_t hardware_shared_size; //!< Number of bytes of shared memory available

    //! state variables below, do not touch!

    int memfd; //!< /dev/mem fd
    void *mapped_register_base;
    void *mapped_shared_base;
    size_t sg_mm2s_size;
    size_t sg_s2mm_size;
    struct xilinx_dma_desc_sg *sg_mm2s_descs;
    struct xilinx_dma_desc_sg *sg_s2mm_descs;
    size_t sg_mm2s_head;
    size_t sg_s2mm_head;
    size_t sg_mm2s_tail;
    size_t sg_s2mm_tail;
} xilinx_user_dma_t;

//! Return error codes
#define XILINX_USER_DMA_OK 0
#define XILINX_USER_DMA_ERROR_COMMS -1 //!< cant communicate with engine
#define XILINX_USER_DMA_ERROR_TIMEOUT -2 //!< wait timeout or loop timeout
#define XILINX_USER_DMA_ERROR_OPEN -3 //!< error calling open()/close()
#define XILINX_USER_DMA_ERROR_MMAP -4 //!< error calling mmap()/munmap()

/*!
 * Create a user DMA instance.
 * \param self the user dma instance structure
 * \return the error code or 0 for success
 */
inline int xilinx_user_dma_create(xilinx_user_dma_t *self);

/*!
 * Destroy a user DMA instance.
 * \param self the user dma instance structure
 * \return the error code or 0 for success
 */
inline int xilinx_user_dma_destroy(xilinx_user_dma_t *self);

/*!
 * Initialize and reset the DMA engine.
 * \param self the user dma instance structure
 * \return the error code or 0 for success
 */
inline int xilinx_user_dma_init_engine(xilinx_user_dma_t *self);

/***********************************************************************
 * Register constants for AXI DMA v7.1
 *
 * Reference material:
 * https://github.com/Xilinx/linux-xlnx/blob/master/drivers/dma/xilinx/xilinx_axidma.c
 * http://www.xilinx.com/support/documentation/ip_documentation/axi_dma/v7_1/pg021_axi_dma.pdf
 **********************************************************************/
/* Register Offsets */
#define XILINX_DMA_CONTROL_OFFSET	0x00 /* Control Reg */
#define XILINX_DMA_STATUS_OFFSET	0x04 /* Status Reg */
#define XILINX_DMA_CDESC_OFFSET	0x08 /* Current descriptor Reg */
#define XILINX_DMA_TDESC_OFFSET	0x10 /* Tail descriptor Reg */
#define XILINX_DMA_SGCTL_OFFSET	0x2C /* SG User and Cache */
#define XILINX_DMA_DMACR_OFFSET	0x30 /* DMA Control Register */
#define XILINX_DMA_DMASR_OFFSET	0x34 /* DMA Status Register */
#define XILINX_DMA_CURSESC_OFFSET	0x38 /* Current descriptor ptr */
#define XILINX_DMA_TAILDESC_OFFSET	0x40 /* Tail descriptor ptr */

/* General register bits definitions */
#define XILINX_DMA_CR_RESET_MASK	0x00000004 /* Reset DMA engine */
#define XILINX_DMA_CR_RUNSTOP_MASK	0x00000001 /* Start/stop DMA engine */
#define XILINX_DMA_SR_HALTED_MASK	0x00000001 /* DMA channel halted */
#define XILINX_DMA_SR_IDLE_MASK	0x00000002 /* DMA channel idle */

/* Delay loop counter to prevent hardware failure */
#define XILINX_DMA_RESET_LOOP	1000000
#define XILINX_DMA_HALT_LOOP	1000000

/* Scatter/Gather descriptor */
typedef struct xilinx_dma_desc_sg
{
    uint32_t next_desc; /* 0x00 */
    uint32_t pad1; /* 0x04 */
    uint32_t buf_addr; /* 0x08 */
    uint32_t pad2; /* 0x0C */
    uint32_t pad3; /* 0x10 */
    uint32_t pad4; /* 0x14 */
    uint32_t control; /* 0x18 */
    uint32_t status; /* 0x1C */
    uint32_t app_0; /* 0x20 */
    uint32_t app_1; /* 0x24 */
    uint32_t app_2; /* 0x28 */
    uint32_t app_3; /* 0x2C */
    uint32_t app_4; /* 0x30 */
} __attribute__ ((aligned (8))) xilinx_dma_desc_sg_t;

#define XILINX_DMA_REGISTER_SIZE 4096

/***********************************************************************
 * Register access
 **********************************************************************/
inline void xudma_poke32(char *base, int offset, uint32_t val)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + offset);
    *p = val;
}

inline uint32_t xudma_peek32(char *base, int offset)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + offset);
    return *p;
}

/***********************************************************************
 * implementation
 **********************************************************************/
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

inline int xilinx_user_dma_create(xilinx_user_dma_t *self)
{
    //clear structure
    self->memfd = -1;
    self->mapped_register_base = NULL;
    self->mapped_shared_base = NULL;
    self->sg_mm2s_size = 0;
    self->sg_s2mm_size = 0;
    self->sg_mm2s_descs = NULL;
    self->sg_s2mm_descs = NULL;
    self->sg_mm2s_head = 0;
    self->sg_s2mm_head = 0;
    self->sg_mm2s_tail = 0;
    self->sg_s2mm_tail = 0;

    //open /dev/mem so we can map physical addresses
    self->memfd = open("/dev/mem", O_RDWR | O_SYNC);
    if (self->memfd < 0) return XILINX_USER_DMA_ERROR_OPEN;

    //map physical addresses into virtual userspace memory
    self->mapped_register_base = mmap(NULL, XILINX_DMA_REGISTER_SIZE,   PROT_READ | PROT_WRITE, MAP_SHARED, self->memfd, self->hardware_register_base);
    self->mapped_shared_base   = mmap(NULL, self->hardware_shared_size, PROT_READ | PROT_WRITE, MAP_SHARED, self->memfd, self->hardware_shared_base);

    //check for map error
    if (self->mapped_register_base == NULL) return XILINX_USER_DMA_ERROR_MMAP;
    if (self->mapped_shared_base == NULL) return XILINX_USER_DMA_ERROR_MMAP;

    return XILINX_USER_DMA_OK;
}

inline int xilinx_user_dma_destroy(xilinx_user_dma_t *self)
{
    if (self->mapped_register_base != NULL)
    {
        if (munmap(self->mapped_register_base, XILINX_DMA_REGISTER_SIZE != 0))
            return XILINX_USER_DMA_ERROR_MMAP;
    }

    if (self->mapped_shared_base != NULL)
    {
        if (munmap(self->mapped_shared_base, self->hardware_shared_size) != 0)
            return XILINX_USER_DMA_ERROR_MMAP;
    }

    if (self->memfd >= 0)
    {
        if (close(self->memfd) != 0)
            return XILINX_USER_DMA_ERROR_OPEN;
    }

    return XILINX_USER_DMA_OK;
}

inline int xilinx_user_dma_init_engine(xilinx_user_dma_t *self)
{
    void *base = self->mapped_register_base;

    //a simple test to check for an expected bit in the first register
    if ((xudma_peek32(base, XILINX_DMA_CONTROL_OFFSET) & 0x2) == 0)
    {
        return XILINX_USER_DMA_ERROR_COMMS;
    }

    //perform a soft reset
    xudma_poke32(base, XILINX_DMA_CONTROL_OFFSET, xudma_peek32(base, XILINX_DMA_CONTROL_OFFSET) | XILINX_DMA_CR_RESET_MASK);
    int loop = XILINX_DMA_RESET_LOOP;
    while ((xudma_peek32(base, XILINX_DMA_CONTROL_OFFSET) & XILINX_DMA_CR_RESET_MASK) != 0)
    {
        if (--loop == 0) return XILINX_USER_DMA_ERROR_TIMEOUT;
    }

    return XILINX_USER_DMA_OK;
}
