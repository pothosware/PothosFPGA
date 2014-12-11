// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_axis_dma_module.h"
#include <linux/io.h>
#include <linux/mm.h>

long pothos_axis_dma_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
    return 0;
}

int pothos_axis_dma_mmap(struct file *filp, struct vm_area_struct *vma)
{
    pothos_axi_dma_device_t *dev = NULL; //TODO

    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);

    //use vma->vm_pgoff to indicate which index

    int ret = ioremap_page_range(vma->vm_start, dev->reg_phys_addr, dev->reg_phys_size, vma->vm_page_prot);
    if (ret != 0)
    {
        return -EIO;
    }

    return 0;
}

int pothos_axis_dma_open(struct inode *inode, struct file *filp)
{
    return 0;
}

int pothos_axis_dma_release(struct inode *inode, struct file *filp)
{
    return 0;
}
