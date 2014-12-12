// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <linux/poll.h> //poll arguments
#include <linux/wait.h> //wait_queue_head_t
#include <linux/cdev.h> //character device

//! The name of this module used in printk
#define MODULE_NAME "pothos_axis_dma"

/*!
 * Per-device configuration, allocations, mappings...
 */
typedef struct
{
    //devfs registration
    dev_t dev_num;
    struct cdev c_dev;
    struct class *cl;

    //wait queue for implementing interrupt waits
    wait_queue_head_t irq_wait;

    //the platform device from probe
    struct platform_device *pdev;

    //dma engine register space
    phys_addr_t regs_phys_addr; //!< hardware address of the registers from device tree
    size_t regs_phys_size; //!< size in bytes of the registers from device tree
    void __iomem *regs_virt_addr; //!< virtual mapping of register space from ioremap

} pothos_axi_dma_device_t;

//! Register an interrupt handler -- called by probe
int pothos_axis_dma_register_irq(unsigned int irq, pothos_axi_dma_device_t *dev);

//! Remove an interrupt handler -- called by unprobe
void pothos_axis_dma_unregister_irq(unsigned int irq, pothos_axi_dma_device_t *dev);

//! The poll implementation used to wait on interrupts
unsigned int pothos_axis_dma_poll(struct file *filp, struct poll_table_struct *wait);

//! IOCTL access for user to control allocations
long pothos_axis_dma_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);

//! Map DMA and device registers into userspace
int pothos_axis_dma_mmap(struct file *filp, struct vm_area_struct *vma);

//! The user calls open on the device node
int pothos_axis_dma_open(struct inode *inode, struct file *filp);

//! The user calls close on the device node
int pothos_axis_dma_release(struct inode *inode, struct file *filp);
