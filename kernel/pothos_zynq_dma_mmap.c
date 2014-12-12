// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_zynq_dma_module.h"
#include <linux/io.h> //ioctl
#include <linux/mm.h> //mmap
#include <linux/of_irq.h> //irq_of_parse_and_map
#include <linux/platform_device.h>
#include <linux/dma-mapping.h>

//! A known point where the axi dma registers alias
#define REG_ALIAS_OFFSET (data->regs_phys_size/2)

long pothos_zynq_dma_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
    pothos_zynq_dma_device_t *data = filp->private_data;

    switch (cmd)
    {
    case POTHOS_ZYNQ_DMA_ALLOC: return pothos_zynq_dma_buffs_alloc(data, (pothos_zynq_dma_alloc_t *)arg);
    case POTHOS_ZYNQ_DMA_FREE: return pothos_zynq_dma_buffs_free(data);
    }

    return -EINVAL;
}

int pothos_zynq_dma_mmap(struct file *filp, struct vm_area_struct *vma)
{
    pothos_zynq_dma_device_t *data = filp->private_data;
    const size_t size = vma->vm_end - vma->vm_start;

    //The user passes in the physical address as the offset.
    //Use vma->vm_pgoff to indicate which DMA allocation.
    if (data->dma_buffs != NULL) for (size_t i = 0; i < data->num_dma_buffs; i++)
    {
        const size_t pfn_addr = data->dma_buffs[i].paddr >> PAGE_SHIFT;
        if (vma->vm_pgoff != pfn_addr) continue;
        return remap_pfn_range(vma, vma->vm_start, pfn_addr, size, vma->vm_page_prot);
    }

    //Use a register alias point to map the registers in to user-space...
    //as the kernel has already iomapped the registers at offset 0.
    if (vma->vm_pgoff == 0) //0 is the register space offset
    {
        vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
        const size_t register_alias = data->regs_phys_addr + REG_ALIAS_OFFSET;
        return io_remap_pfn_range(vma, vma->vm_start, register_alias >> PAGE_SHIFT, size, vma->vm_page_prot);
    }
    return -EINVAL;
}

int pothos_zynq_dma_open(struct inode *inode, struct file *filp)
{
    //find the base of the data structure by seeing where cdev is stored
    pothos_zynq_dma_device_t *data = container_of(inode->i_cdev, pothos_zynq_dma_device_t, c_dev);
    filp->private_data = data; /* now store it to private data for other methods */

    struct platform_device *pdev = data->pdev;
    struct device_node *node = pdev->dev.of_node;
    dev_info(&pdev->dev, "Open %s\n", of_node_full_name(node));

    init_waitqueue_head(&data->irq_wait);

    //register interrupt handlers
    for (size_t i = 0; (1); i++)
    {
        unsigned int irq = irq_of_parse_and_map(node, i);
        if (irq == 0) break;
        dev_info(&pdev->dev, "Register IRQ %d.\n", irq);
        int ret = pothos_zynq_dma_register_irq(irq, data);
        if (ret != 0)
        {
            dev_err(&pdev->dev, "Error %d registering IRQ %d.\n", ret, irq);
            return -EIO;
        }
    }

    //io map the device register space
    //note, we ignore the register size and use the smaller constant below
    //so we can map an alias to the registers again in the mmap routine
    data->regs_virt_addr = ioremap_nocache(data->regs_phys_addr, REG_ALIAS_OFFSET);
    if (data->regs_virt_addr == NULL)
    {
        dev_err(&pdev->dev, "Error mapping register resource.\n");
        return -EIO;
    }

    //initialize members
    data->num_dma_buffs = 0;
    data->dma_buffs = NULL;

    data->test_dma_virt_mem = dma_zalloc_coherent(&pdev->dev, 1024, &data->test_dma_phys_mem, GFP_KERNEL);
    if (data->test_dma_virt_mem == NULL)
    {
        dev_err(&pdev->dev, "Error mapping DMA resource.\n");
        return -EIO;
    }

    return 0;
}

int pothos_zynq_dma_release(struct inode *inode, struct file *filp)
{
    pothos_zynq_dma_device_t *data = filp->private_data;
    struct platform_device *pdev = data->pdev;
    struct device_node *node = pdev->dev.of_node;
    dev_info(&pdev->dev, "Release %s\n", of_node_full_name(node));

    //unregister irq
    for (size_t i = 0; (1); i++)
    {
        unsigned int irq = irq_of_parse_and_map(node, i);
        if (irq == 0) break;
        dev_info(&pdev->dev, "Unregister IRQ %d.\n", irq);
        pothos_zynq_dma_register_irq(irq, data);
    }

    //unmap registers
    iounmap(data->regs_virt_addr);

    //free DMA buffers if not freed by the user
    pothos_zynq_dma_buffs_free(data);

    dma_free_coherent(&pdev->dev, 1024, data->test_dma_virt_mem, data->test_dma_phys_mem);

    return 0;
}
