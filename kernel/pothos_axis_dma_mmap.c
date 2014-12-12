// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_axis_dma_module.h"
#include <linux/kernel.h>
#include <linux/io.h> //ioctl
#include <linux/mm.h> //mmap
#include <linux/of_irq.h> //irq_of_parse_and_map
#include <linux/platform_device.h>

long pothos_axis_dma_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
    pothos_axi_dma_device_t *data = filp->private_data;

    return 0;
}

int pothos_axis_dma_mmap(struct file *filp, struct vm_area_struct *vma)
{
    pothos_axi_dma_device_t *data = filp->private_data;

    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
    return remap_pfn_range(
        vma, vma->vm_start, data->regs_phys_addr >> PAGE_SHIFT,
        vma->vm_end - vma->vm_start, vma->vm_page_prot);
}

int pothos_axis_dma_open(struct inode *inode, struct file *filp)
{
    //find the base of the data structure by seeing where cdev is stored
    pothos_axi_dma_device_t *data = container_of(inode->i_cdev, pothos_axi_dma_device_t, c_dev);
    filp->private_data = data; /* now store it to private data for other methods */

    struct platform_device *pdev = data->pdev;
    struct device_node *node = pdev->dev.of_node;

    init_waitqueue_head(&data->irq_wait);

    //register interrupt handlers
    for (size_t i = 0; (1); i++)
    {
        unsigned int irq = irq_of_parse_and_map(node, i);
        if (irq == 0) break;
        int ret = pothos_axis_dma_register_irq(irq, data);
        if (ret != 0)
        {
            dev_err(&pdev->dev, "Error %d registering IRQ %d.\n", ret, irq);
            return -EIO;
        }
    }

    //io map the device register space (we dont unmap)
    struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (res == NULL)
    {
        dev_err(&pdev->dev, "Error getting register resource.\n");
        return -EIO;
    }
    data->regs_phys_addr = res->start;
    data->regs_phys_size = resource_size(res);
    /*
    data->regs_virt_addr = devm_ioremap_resource(&pdev->dev, res);
    if (data->regs_virt_addr == NULL)
    {
        dev_err(&pdev->dev, "Error mapping register resource.\n");
        return -EIO;
    }
    dev_info(&pdev->dev, "reg0 = 0x%x\n", ioread32(data->regs_virt_addr));
    */

    return 0;
}

int pothos_axis_dma_release(struct inode *inode, struct file *filp)
{
    pothos_axi_dma_device_t *data = filp->private_data;
    struct platform_device *pdev = data->pdev;
    struct device_node *node = pdev->dev.of_node;

    //unregister irq
    for (size_t i = 0; (1); i++)
    {
        unsigned int irq = irq_of_parse_and_map(node, i);
        if (irq == 0) break;
        pothos_axis_dma_register_irq(irq, data);
    }

    return 0;
}
