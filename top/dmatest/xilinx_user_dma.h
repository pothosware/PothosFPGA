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
    //------------------------------------------------------------------
    //-- configuration variables: set by user at init
    //------------------------------------------------------------------

    size_t hardware_register_base; //!< Hardware address for start of DMA registers

    size_t hardware_shared_base; //!< Hardware address for start of shared memory
    size_t hardware_shared_size; //!< Number of bytes of shared memory available

    size_t mm2s_buffer_size; //!< The size of one "memory map to stream" buffer
    size_t s2mm_buffer_size; //!< The size of one "stream to memory map" buffer

    size_t mm2s_num_buffers; //!< The number of one "memory map to stream" buffers
    size_t s2mm_num_buffers; //!< The number of one "stream to memory map" buffers

    //------------------------------------------------------------------
    //-- state variables below, do not touch!
    //------------------------------------------------------------------

    int memfd; //!< /dev/mem fd
    void *mapped_register_base;
    void *mapped_shared_base;
    struct xilinx_dma_desc_sg *mm2s_descs;
    struct xilinx_dma_desc_sg *s2mm_descs;
    size_t mm2s_head;
    size_t s2mm_head;
    size_t mm2s_tail;
    size_t s2mm_tail;
} xilinx_user_dma_t;

//! Return error codes
#define XILINX_USER_DMA_OK 0
#define XILINX_USER_DMA_ERROR_COMMS -1 //!< cant communicate with engine
#define XILINX_USER_DMA_ERROR_TIMEOUT -2 //!< wait timeout or loop timeout
#define XILINX_USER_DMA_ERROR_OPEN -3 //!< error calling open()/close()
#define XILINX_USER_DMA_ERROR_MMAP -4 //!< error calling mmap()/munmap()
#define XILINX_USER_DMA_ERROR_ALLOC -5 //!< error allocating DMA buffers

//! Direction constants
#define XILINX_USER_DMA_MM2S 1
#define XILINX_USER_DMA_S2MM 2

/*!
 * Create a user DMA instance.
 * \param self the user dma instance structure
 * \return the error code or 0 for success
 */
static inline int xilinx_user_dma_create(xilinx_user_dma_t *self);

/*!
 * Destroy a user DMA instance.
 * \param self the user dma instance structure
 * \return the error code or 0 for success
 */
static inline int xilinx_user_dma_destroy(xilinx_user_dma_t *self);

/*!
 * Initialize and reset the DMA engine.
 * \param self the user dma instance structure
 * \param dir the direction MM2S or S2MM
 * \return the error code or 0 for success
 */
static inline int xilinx_user_dma_init(xilinx_user_dma_t *self, int dir);

/*!
 * Halt/stop all ongoing transfer activity.
 * \param self the user dma instance structure
 * \param dir the direction MM2S or S2MM
 * \return the error code or 0 for success
 */
static inline int xilinx_user_dma_halt(xilinx_user_dma_t *self, int dir);

//! Buffer structure for use with acquire/release
typedef struct
{
    size_t handle; //!< handle used for release calls
    void *buff; //!< pointer to virtual memory
    size_t length; //!< length of the buffer in bytes
} xilinx_user_dma_buffer_t;

/*!
 * Acquire a stream to memory map buffer.
 * The buffer->length value has the number of bytes filled by the transfer.
 * \param buffer [out] the buffer structure
 * \param timeout_us the time to wait in microseconds
 * \return the error code or 0 for success
 */
static inline int xilinx_user_dma_s2mm_acquire(xilinx_user_dma_buffer_t *buffer, long timeout_us);

/*!
 * Release a stream to memory map buffer.
 * Returns immediately, no errors.
 * \param handle the handle value from the acquire result
 */
static inline void xilinx_user_dma_s2mm_release(size_t handle);

/*!
 * Acquire a memory map to stream buffer.
 * The buffer->length value has the number of bytes available in buff.
 * \param buffer [out] the buffer structure
 * \param timeout_us the time to wait in microseconds
 * \return the error code or 0 for success
 */
static inline int xilinx_user_dma_mm2s_acquire(xilinx_user_dma_buffer_t *buffer, long timeout_us);

/*!
 * Release a memory map to stream buffer.
 * Returns immediately, no errors.
 * \param handle the handle value from the acquire result
 * \param length the actual number of bytes in the buffer
 */
static inline void xilinx_user_dma_mm2s_release(size_t handle, size_t length);

/***********************************************************************
 * Register constants for AXI DMA v7.1
 *
 * Reference material:
 * https://github.com/Xilinx/linux-xlnx/blob/master/drivers/dma/xilinx/xilinx_axidma.c
 * http://www.xilinx.com/support/documentation/ip_documentation/axi_dma/v7_1/pg021_axi_dma.pdf
 **********************************************************************/
/* Register Offsets */
#define XILINX_DMA_MM2S_DMACR_OFFSET 0x00
#define XILINX_DMA_MM2S_DMASR_OFFSET 0x04
#define XILINX_DMA_MM2S_CURDESC_OFFSET 0x08
#define XILINX_DMA_MM2S_TAILDESC_OFFSET 0x10
#define XILINX_DMA_SG_CTL_OFFSET 0x2C
#define XILINX_DMA_S2MM_DMACR_OFFSET 0x30
#define XILINX_DMA_S2MM_DMASR_OFFSET 0x34
#define XILINX_DMA_S2MM_CURDESC_OFFSET 0x38
#define XILINX_DMA_S2MM_TAILDESC_OFFSET 0x40
#define XILINX_DMA_REGISTER_SIZE 0x41 //size of usable register space

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
} __attribute__ ((aligned (64))) xilinx_dma_desc_t;

/***********************************************************************
 * Register access
 **********************************************************************/
static inline void xudma_poke32(char *base, int offset, uint32_t val)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + offset);
    *p = val;
}

static inline uint32_t xudma_peek32(char *base, int offset)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + offset);
    return *p;
}

/***********************************************************************
 * implementation
 **********************************************************************/
#include <sys/types.h> //open
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h> //mmap
#include <unistd.h> //close

static inline int xilinx_user_dma_create(xilinx_user_dma_t *self)
{
    //clear structure
    self->memfd = -1;
    self->mapped_register_base = NULL;
    self->mapped_shared_base = NULL;
    self->mm2s_descs = NULL;
    self->s2mm_descs = NULL;
    self->mm2s_head = 0;
    self->s2mm_head = 0;
    self->mm2s_tail = 0;
    self->s2mm_tail = 0;

    //open /dev/mem so we can map physical addresses
    self->memfd = open("/dev/mem", O_RDWR | O_SYNC);
    if (self->memfd < 0) return XILINX_USER_DMA_ERROR_OPEN;

    //map physical addresses into virtual userspace memory
    self->mapped_register_base = mmap(NULL, XILINX_DMA_REGISTER_SIZE,   PROT_READ | PROT_WRITE, MAP_SHARED, self->memfd, self->hardware_register_base);
    self->mapped_shared_base   = mmap(NULL, self->hardware_shared_size, PROT_READ | PROT_WRITE, MAP_SHARED, self->memfd, self->hardware_shared_base);

    //check for map error
    if (self->mapped_register_base == NULL) return XILINX_USER_DMA_ERROR_MMAP;
    if (self->mapped_shared_base == NULL) return XILINX_USER_DMA_ERROR_MMAP;

    //setup scatter gather descriptors
    size_t alloc_off = 0;

    self->mm2s_descs = (xilinx_dma_desc_t *)((size_t)self->mapped_shared_base+alloc_off);
    alloc_off += sizeof(xilinx_dma_desc_t)*self->mm2s_num_buffers;

    self->s2mm_descs = (xilinx_dma_desc_t *)((size_t)self->mapped_shared_base+alloc_off);
    alloc_off += sizeof(xilinx_dma_desc_t)*self->s2mm_num_buffers;

    for (size_t i = 0; i < self->mm2s_num_buffers; i++)
    {
        xilinx_dma_desc_t *desc = self->mm2s_descs + i;
        size_t next_index = (i+1) % self->mm2s_num_buffers;
        desc->next_desc = (uint32_t)(self->mm2s_descs + next_index);
        desc->next_desc -= (size_t)self->mapped_shared_base;
        desc->next_desc += self->hardware_shared_base;
        desc->buf_addr = alloc_off + self->hardware_shared_base;
        alloc_off += self->mm2s_buffer_size;
    }

    for (size_t i = 0; i < self->s2mm_num_buffers; i++)
    {
        xilinx_dma_desc_t *desc = self->s2mm_descs + i;
        size_t next_index = (i+1) % self->s2mm_num_buffers;
        desc->next_desc = (uint32_t)(self->s2mm_descs + next_index);
        desc->next_desc -= (size_t)self->mapped_shared_base;
        desc->next_desc += self->hardware_shared_base;
        desc->buf_addr = alloc_off + self->hardware_shared_base;
        alloc_off += self->s2mm_buffer_size;
    }

    //check if we over-allocated resources
    if (alloc_off > self->hardware_shared_size) return XILINX_USER_DMA_ERROR_ALLOC;

    return XILINX_USER_DMA_OK;
}

static inline int xilinx_user_dma_destroy(xilinx_user_dma_t *self)
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

static inline int xilinx_user_dma_init(xilinx_user_dma_t *self, int dir)
{
    void *base = self->mapped_register_base;
    int offset = (dir == XILINX_USER_DMA_MM2S)?XILINX_DMA_MM2S_DMACR_OFFSET:XILINX_DMA_S2MM_DMACR_OFFSET;

    //a simple test to check for an expected bit in the first register
    if ((xudma_peek32(base, offset) & 0x2) == 0)
    {
        return XILINX_USER_DMA_ERROR_COMMS;
    }

    //perform a soft reset and wait for done
    xudma_poke32(base, offset, xudma_peek32(base, offset) | XILINX_DMA_CR_RESET_MASK);
    int loop = XILINX_DMA_RESET_LOOP;
    while ((xudma_peek32(base, offset) & XILINX_DMA_CR_RESET_MASK) != 0)
    {
        if (--loop == 0) return XILINX_USER_DMA_ERROR_TIMEOUT;
    }

    return XILINX_USER_DMA_OK;
}

static inline int xilinx_user_dma_halt(xilinx_user_dma_t *self, int dir)
{
    void *base = self->mapped_register_base;
    int offset = (dir == XILINX_USER_DMA_MM2S)?XILINX_DMA_MM2S_DMACR_OFFSET:XILINX_DMA_S2MM_DMACR_OFFSET;

    //perform a halt and wait for done
    xudma_poke32(base, offset, xudma_peek32(base, offset) | ~XILINX_DMA_CR_RUNSTOP_MASK);
    int loop = XILINX_DMA_HALT_LOOP;
    while ((xudma_peek32(base, offset) & XILINX_DMA_CR_RUNSTOP_MASK) != 0)
    {
        if (--loop == 0) return XILINX_USER_DMA_ERROR_TIMEOUT;
    }

    return XILINX_USER_DMA_OK;
}

static inline int xilinx_user_dma_s2mm_acquire(xilinx_user_dma_buffer_t *buffer, long timeout_us)
{
    //wait on head available

    //fill in the buffer structure

    //increment to next
}

static inline void xilinx_user_dma_s2mm_release(size_t handle)
{
    //increment tail and check ahead
}

static inline int xilinx_user_dma_mm2s_acquire(xilinx_user_dma_buffer_t *buffer, long timeout_us)
{
    
}

static inline void xilinx_user_dma_mm2s_release(size_t handle, size_t length)
{
    
}
