// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <linux/poll.h> //poll arguments
#include <linux/wait.h> //wait_queue_head_t

//! The name of this module used in printk
#define MODULE_NAME "pothos_axis_dma"

/*!
 * Per-device configuration, allocations, mappings...
 */
typedef struct
{
    struct device_node *node;
    wait_queue_head_t irq_wait;

} pothos_axi_dma_device_t;

//! Probe the device tree for available hw
void pothos_axis_dma_probe(void);

//! Cleanup from probe when module unloaded
void pothos_axis_dma_unprobe(void);

//! Register an interrupt handler -- called by probe
int pothos_axis_dma_register_irq(unsigned int irq, pothos_axi_dma_device_t *dev);

//! Remove an interrupt handler -- called by unprobe
void pothos_axis_dma_unregister_irq(unsigned int irq, pothos_axi_dma_device_t *dev);

//! The poll implementation used to wait on interrupts
unsigned int pothos_axis_dma_poll(struct file *filp, struct poll_table_struct *wait);

//! Map DMA and device registers into userspace
int pothos_axis_dma_mmap(struct file *filp, struct vm_area_struct *vma);

//! The user calls open on the device node
int pothos_axis_dma_open(struct inode *inode, struct file *filp);

//! The user calls close on the device node
int pothos_axis_dma_release(struct inode *inode, struct file *filp);
