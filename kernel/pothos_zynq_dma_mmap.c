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

    return 0;
}

int pothos_zynq_dma_mmap(struct file *filp, struct vm_area_struct *vma)
{
    pothos_zynq_dma_device_t *data = filp->private_data;
    struct platform_device *pdev = data->pdev;

    //use vma->vm_pgoff to indicate which index
    dev_info(&pdev->dev, "mmap with vm_pgoff %lu.\n", vma->vm_pgoff);
    if (vma->vm_pgoff > 0)
    {
        return remap_pfn_range(vma, vma->vm_start, (data->test_dma_phys_mem) >> PAGE_SHIFT, 1024, vma->vm_page_prot);
    }

    //use a register alias point to map the registers in to user-space
    //as the kernel has already iomapped the registers at offset 0
    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    const size_t register_alias = data->regs_phys_addr + REG_ALIAS_OFFSET;
    return io_remap_pfn_range(vma, vma->vm_start, register_alias >> PAGE_SHIFT, vma->vm_end - vma->vm_start, vma->vm_page_prot);
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

    dma_free_coherent(&pdev->dev, 1024, data->test_dma_virt_mem, data->test_dma_phys_mem);

    return 0;
}
