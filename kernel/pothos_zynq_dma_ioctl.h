// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <linux/ioctl.h>
#include <linux/types.h>

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
 * Used to allocate DMA buffer specified by the pothos_zynq_dma_ioctl_t
 * The addresses will be filled in on successful allocations otherwise 0.
 * A second call will fail unless the user first performs POTHOS_ZYNQ_DMA_FREE.
 * The user must call mmap with paddr as the offset to fill in the uaddr.
 */
#define POTHOS_ZYNQ_DMA_ALLOC _IOWR('p', 1, pothos_zynq_dma_alloc_t *)

/*!
 * Free all allocations performed by POTHOS_ZYNQ_DMA_ALLOC.
 */
#define POTHOS_ZYNQ_DMA_FREE _IO('p', 2)
