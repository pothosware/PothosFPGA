// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <linux/ioctl.h>
#include <linux/types.h>

//! The mmap offset used to specify the register space
#define POTHOS_ZYNQ_DMA_REGS_OFF 0

//! The size in bytes of the register space of interest
#define POTHOS_ZYNQ_DMA_REGS_SIZE 1024

/*!
 * A descriptor for a single DMA buffer.
 */
typedef struct
{
    size_t bytes; //!< the number of bytes to allocate
    size_t paddr; //!< the physical address of the memory
    void *kaddr; //!< the kernel address of the memory
    void *uaddr; //!< the userspace address of the memory
} pothos_zynq_dma_buff_t;

//! Change this when the structure changes
#define POTHOS_ZYNQ_DMA_SENTINEL 0x1d89ab0d

/*!
 * The IOCTL structured used to request allocations.
 * The addresses will be filled in on successful allocations with ioctl.
 * The user must call mmap with paddr as the offset to fill in the uaddr.
 */
typedef struct
{
    //! A expected word for ABI compatibility checks
    unsigned int sentinel;

    //! The number of DMA buffers
    size_t num_buffs;

    //! An array of DMA buffers
    pothos_zynq_dma_buff_t *buffs;

} pothos_zynq_dma_alloc_t;

/*!
 * Used to allocate stream to memory map buffers specified by the pothos_zynq_dma_ioctl_t
 * A second call will fail unless the user first performs POTHOS_ZYNQ_DMA_FREE_S2MM.
 */
#define POTHOS_ZYNQ_DMA_ALLOC_S2MM _IOWR('p', 1, pothos_zynq_dma_alloc_t *)

/*!
 * Used to allocate memory map to stream buffers specified by the pothos_zynq_dma_ioctl_t
 * A second call will fail unless the user first performs POTHOS_ZYNQ_DMA_FREE_MM2S.
 */
#define POTHOS_ZYNQ_DMA_ALLOC_MM2S _IOWR('p', 2, pothos_zynq_dma_alloc_t *)

//! Free all allocations performed by POTHOS_ZYNQ_DMA_ALLOC_S2MM
#define POTHOS_ZYNQ_DMA_FREE_S2MM _IO('p', 3)

//! Free all allocations performed by POTHOS_ZYNQ_DMA_ALLOC_MM2S
#define POTHOS_ZYNQ_DMA_FREE_MM2S _IO('p', 4)
