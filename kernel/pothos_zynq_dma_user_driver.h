// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

/***********************************************************************
 * AXI DMA v7.1 userspace driver for Scatter/Gather mode
 **********************************************************************/

#pragma once
#include <stddef.h>
#include <stdint.h>

//! Return error codes
#define PZDUD_OK 0
#define PZDUD_ERROR_COMMS -1 //!< cant communicate with engine
#define PZDUD_ERROR_TIMEOUT -2 //!< wait timeout or loop timeout
#define PZDUD_ERROR_MAP -4 //!< error calling mmap()/munmap()
#define PZDUD_ERROR_ALLOC -5 //!< error allocating DMA buffers
#define PZDUD_ERROR_CLAIMED -6 //!< all buffers claimed by the user
#define PZDUD_ERROR_COMPLETE -7 //!< no completed buffer transactions

//! Direction constants to specify memory to/from stream
typedef enum pzdud_dir
{
    PZDUD_S2MM,
    PZDUD_MM2S,
} pzdud_dir_t;

//! opaque struct for dma driver instance
struct pzdud;
typedef struct pzdud pzdud_t;

/*!
 * Create a user DMA instance.
 * \param index the index of an AXI DMA in the device tree
 * \return the user dma instance structure or NULL on error
 */
static inline pzdud_t *pzdud_create(const size_t index);

/*!
 * Destroy a user DMA instance.
 * \param self the user dma instance structure
 * \return the error code or 0 for success
 */
static inline int pzdud_destroy(pzdud_t *self);

/*!
 * Reset the DMA engine.
 * \param self the user dma instance structure
 * \return the error code or 0 for success
 */
static inline int pzdud_reset(pzdud_t *self);

/*!
 * Allocate buffers and setup the scatter/gather table.
 * Call pzdud_alloc before initializing the engine.
 * \param self the user dma instance structure
 * \param dir the direction to/from stream
 * \param num_buffs the number of buffers in the table
 * \param buff_size the size of the buffers in bytes
 * \return the error code or 0 for success
 */
static inline int pzdud_alloc(pzdud_t *self, const pzdud_dir_t dir, const size_t num_buffs, const size_t buff_size);

/*!
 * Free buffers allocated by pzdud_alloc.
 * Only call pzdud_free when the engine is halted.
 * \param self the user dma instance structure
 * \param dir the direction to/from stream
 * \return the error code or 0 for success
 */
static inline int pzdud_free(pzdud_t *self, const pzdud_dir_t dir);

/*!
 * Initialize the DMA engine for streaming.
 * The engine will be ready to receive streams.
 * \param self the user dma instance structure
 * \param dir the direction to/from stream
 * \return the error code or 0 for success
 */
static inline int pzdud_init(pzdud_t *self, const pzdud_dir_t dir);

/*!
 * Halt/stop all ongoing transfer activity.
 * \param self the user dma instance structure
 * \param dir the direction to/from stream
 * \return the error code or 0 for success
 */
static inline int pzdud_halt(pzdud_t *self, const pzdud_dir_t dir);

/*!
 * Acquire a DMA buffer from the engine.
 * The length value has the number of bytes filled by the transfer.
 * Return PZDUD_ERROR_COMPLETE when there are no completed transactions.
 * Return PZDUD_ERROR_CLAIMED when the user has acquired all buffers.
 * Otherwise return a handle that can be used to release the buffer.
 *
 * \param self the user dma instance structure
 * \param dir the direction to/from stream
 * \param [out] buffer the buffer pointer
 * \param [out] length the buffer length in bytes
 * \return the handle or negative error code
 */
static inline int pzdud_acquire(pzdud_t *self, const pzdud_dir_t dir, void **buffer, size_t *length);

/*!
 * Release a DMA buffer back the engine.
 * Returns immediately, no errors.
 * \param self the user dma instance structure
 * \param dir the direction to/from stream
 * \param length the length in bytes to submit (MM2S only)
 * \param handle the handle value from the acquire result
 */
static inline void pzdud_release(pzdud_t *self, const pzdud_dir_t dir, size_t handle, size_t length);

/***********************************************************************
 * implementation
 **********************************************************************/
#include <stdlib.h>
#include "pothos_zynq_dma_ioctl.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h> //mmap
#include <unistd.h> //close

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
#define XILINX_DMA_XR_IRQ_IOC_MASK	0x00001000 /* Completion interrupt */
#define XILINX_DMA_XR_IRQ_DELAY_MASK	0x00002000 /* Delay interrupt */
#define XILINX_DMA_XR_IRQ_ERROR_MASK	0x00004000 /* Error interrupt */
#define XILINX_DMA_XR_IRQ_ALL_MASK	0x00007000 /* All interrupts */
#define XILINX_DMA_XR_DELAY_MASK	0xFF000000 /* Delay timeout counter */
#define XILINX_DMA_XR_COALESCE_MASK	0x00FF0000 /* Coalesce counter */
#define XILINX_DMA_DELAY_SHIFT	24 /* Delay timeout counter shift */
#define XILINX_DMA_COALESCE_SHIFT	16 /* Coalesce counter shift */
#define XILINX_DMA_DELAY_MAX	0xFF /* Maximum delay counter value */
#define XILINX_DMA_COALESCE_MAX	0xFF /* Max coalescing counter value */
#define XILINX_DMA_RX_CHANNEL_OFFSET	0x30 /* S2MM Channel Offset */

/* BD definitions for AXI Dma */
#define XILINX_DMA_BD_STS_ALL_MASK	0xF0000000
#define XILINX_DMA_BD_SOP	0x08000000 /* Start of packet bit */
#define XILINX_DMA_BD_EOP	0x04000000 /* End of packet bit */

/* Feature encodings */
#define XILINX_DMA_FTR_HAS_SG	0x00000100 /* Has SG */
#define XILINX_DMA_FTR_HAS_SG_SHIFT	8 /* Has SG shift */

/* Optional feature for dma */
#define XILINX_DMA_FTR_STSCNTRL_STRM	0x00010000

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
 * Definition for instance data
 **********************************************************************/
struct pzdud
{
    int fd; //!< file descriptor for device node
    void *regs; //!< mapped register space

    pothos_zynq_dma_alloc_t s2mm_allocs;
    pothos_zynq_dma_alloc_t mm2s_allocs;
};

/***********************************************************************
 * Helper functions
 **********************************************************************/
static inline void __pzdud_write32(char *base, int offset, uint32_t val)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + offset);
    *p = val;
}

static inline uint32_t __pzdud_read32(char *base, int offset)
{
    volatile uint32_t *p = (volatile uint32_t *)(base + offset);
    return *p;
}

/***********************************************************************
 * create/destroy implementation
 **********************************************************************/
static inline pzdud_t *pzdud_create(const size_t index)
{
    //format the expected device name
    char device_name[1024];
    if (snprintf(device_name, sizeof(device_name), "/dev/pothos_zynq_dma%d", index) <= 0)
    {
        printf("Failed to format a device name\n");
        return NULL;
    }

    //open the device
    int fd = open(device_name, O_RDWR | O_SYNC);
    if (fd <= 0)
    {
        perror("pzdud_create::open()");
        return NULL;
    }

    //map the register space
    void *regs = mmap(NULL, POTHOS_ZYNQ_DMA_REGS_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, POTHOS_ZYNQ_DMA_REGS_OFF);
    if (regs == MAP_FAILED)
    {
        perror("pzdud_create::mmap(regs)");
        return NULL;
    }

    //initialize the object structure
    pzdud_t *self = (pzdud_t *)malloc(sizeof(pzdud_t));
    self->fd = fd;
    self->regs = regs;
    self->s2mm_allocs.buffs = NULL;
    self->s2mm_allocs.num_buffs = 0;
    self->mm2s_allocs.buffs = NULL;
    self->mm2s_allocs.num_buffs = 0;
    return self;
}

static inline int pzdud_destroy(pzdud_t *self)
{
    munmap(self->regs, POTHOS_ZYNQ_DMA_REGS_SIZE);
    close(self->fd);
    free(self);
    return PZDUD_OK;
}

/***********************************************************************
 * reset implementation
 **********************************************************************/
static inline int __pzdud_reset(pzdud_t *self, const size_t dmacr_offset)
{
    int loop = 0;

    //a simple test to check for an expected bit in the first register
    if ((__pzdud_read32(self->regs, dmacr_offset) & 0x2) == 0) return PZDUD_ERROR_COMMS;

    //perform a soft reset and wait for done
    const uint32_t reg = __pzdud_read32(self->regs, dmacr_offset);
    __pzdud_write32(self->regs, dmacr_offset, reg | XILINX_DMA_CR_RESET_MASK);
    loop = XILINX_DMA_RESET_LOOP;
    while ((__pzdud_read32(self->regs, dmacr_offset) & XILINX_DMA_CR_RESET_MASK) != 0)
    {
        if (--loop == 0) return PZDUD_ERROR_TIMEOUT;
    }

    return PZDUD_OK;
}

static inline int pzdud_reset(pzdud_t *self)
{
    int ret = PZDUD_OK;

    ret = __pzdud_reset(self, XILINX_DMA_S2MM_DMACR_OFFSET);
    if (ret != PZDUD_OK) return ret;

    ret = __pzdud_reset(self, XILINX_DMA_MM2S_DMACR_OFFSET);
    if (ret != PZDUD_OK) return ret;

    return ret;
}

/***********************************************************************
 * allocation implementation
 **********************************************************************/
static inline int pzdud_alloc(pzdud_t *self, const pzdud_dir_t dir, const size_t num_buffs, const size_t buff_size)
{
    pothos_zynq_dma_alloc_t *allocs = (dir == PZDUD_S2MM)?&self->s2mm_allocs:&self->mm2s_allocs;

    //load up the allocation request
    allocs->sentinel = POTHOS_ZYNQ_DMA_SENTINEL;
    allocs->num_buffs = num_buffs + 1; //num+SG
    allocs->buffs = (pothos_zynq_dma_buff_t *)calloc(allocs->num_buffs, sizeof(pothos_zynq_dma_buff_t));
    for (size_t i = 0; i < num_buffs; i++)
    {
        allocs->buffs[i].bytes = buff_size;
    }
    allocs->buffs[num_buffs].bytes = num_buffs*sizeof(xilinx_dma_desc_t);

    //perform the allocation ioctl
    int ret = ioctl(self->fd, (dir == PZDUD_S2MM)?POTHOS_ZYNQ_DMA_ALLOC_S2MM:POTHOS_ZYNQ_DMA_ALLOC_MM2S, (void *)allocs);
    if (ret != 0)
    {
        perror("pzdud_alloc::ioctl()");
        return PZDUD_ERROR_ALLOC;
    }

    //check the results and mmap
    for (size_t i = 0; i < allocs->num_buffs; i++)
    {
        pothos_zynq_dma_buff_t *buff = allocs->buffs + i;
        if (buff->paddr == 0 || buff->kaddr == NULL)
        {
            ioctl(self->fd, (dir == PZDUD_S2MM)?POTHOS_ZYNQ_DMA_FREE_S2MM:POTHOS_ZYNQ_DMA_FREE_MM2S);
            return PZDUD_ERROR_ALLOC;
        }
        buff->uaddr = mmap(NULL, buff->bytes, PROT_READ | PROT_WRITE, MAP_SHARED, self->fd, buff->paddr);
        if (buff->uaddr == MAP_FAILED)
        {
            ioctl(self->fd, (dir == PZDUD_S2MM)?POTHOS_ZYNQ_DMA_FREE_S2MM:POTHOS_ZYNQ_DMA_FREE_MM2S);
            return PZDUD_ERROR_MAP;
        }
    }

    return PZDUD_OK;
}

static inline int pzdud_free(pzdud_t *self, const pzdud_dir_t dir)
{
    pothos_zynq_dma_alloc_t *allocs = (dir == PZDUD_S2MM)?&self->s2mm_allocs:&self->mm2s_allocs;

    //unmap all the buffers
    for (size_t i = 0; i < allocs->num_buffs; i++)
    {
        pothos_zynq_dma_buff_t *buff = allocs->buffs + i;
        munmap(buff->uaddr, buff->bytes);
    }

    //free all the buffers
    int ret = ioctl(self->fd, (dir == PZDUD_S2MM)?POTHOS_ZYNQ_DMA_FREE_S2MM:POTHOS_ZYNQ_DMA_FREE_MM2S);
    if (ret != 0)
    {
        perror("pzdud_free::ioctl()");
        return PZDUD_ERROR_ALLOC;
    }

    //free the container
    free(allocs->buffs);
    allocs->buffs = NULL;
    allocs->num_buffs = 0;

    return PZDUD_OK;
}

/***********************************************************************
 * init/halt implementation
 **********************************************************************/
static inline int pzdud_init(pzdud_t *self, const pzdud_dir_t dir)
{
    
    return PZDUD_OK;
}

static inline int pzdud_halt(pzdud_t *self, const pzdud_dir_t dir)
{
    
    return PZDUD_OK;
}
