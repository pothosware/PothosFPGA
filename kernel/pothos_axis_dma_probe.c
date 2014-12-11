// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_axis_dma_module.h"
#include <linux/slab.h> //kmalloc, kfree
#include <linux/of.h>
#include <linux/of_irq.h>
#include <linux/io.h> //ioremap

static pothos_axi_dma_device_t *devices = NULL;
static size_t num_devices = 0;

void pothos_axis_dma_probe(void)
{
    //allocate space for all of the devices
    num_devices = 0;
    struct device_node *node = NULL;
    for_each_compatible_node(node, NULL, "xlnx,axi-dma")
    {
        num_devices++;
        devices = (pothos_axi_dma_device_t *)krealloc(devices, num_devices*sizeof(pothos_axi_dma_device_t), GFP_KERNEL);
        devices[num_devices-1].node = node;
    }

    //initialize the device structures
    for (size_t devno = 0; devno < num_devices; devno++)
    {
        pothos_axi_dma_device_t *device = devices+devno;
        node = device->node;

        printk(KERN_INFO MODULE_NAME " probe: found %s\n", of_node_full_name(node));
        init_waitqueue_head(&device->irq_wait);

        //register interrupt handlers
        for (size_t i = 0; (1); i++)
        {
            unsigned int irq = irq_of_parse_and_map(node, i);
            if (irq == 0) break;
            printk(KERN_INFO MODULE_NAME " probe: register IRQ %u\n", irq);
            int ret = pothos_axis_dma_register_irq(irq, device);
            if (ret != 0) printk(KERN_INFO MODULE_NAME " probe: register IRQ FAIL %d\n", ret);
        }

        //determine register space
        u32 addr = 0, size = 0;
        of_property_read_u32_index(node, "reg", 0, &addr);
        of_property_read_u32_index(node, "reg", 1, &size);
        printk(KERN_INFO MODULE_NAME " probe: found registers - addr: 0x%x, size: 0x%x\n", addr, size);

        //map the register space
        device->reg_phys_addr = addr;
        device->reg_phys_size = size;
        device->reg_virt_addr = ioremap_nocache(addr, size);
    }
}

void pothos_axis_dma_unprobe(void)
{
    for (size_t devno = 0; devno < num_devices; devno++)
    {
        pothos_axi_dma_device_t *device = devices+devno;

        //unregister irq
        for (size_t i = 0; (1); i++)
        {
            unsigned int irq = irq_of_parse_and_map(device->node, i);
            if (irq == 0) break;
            pothos_axis_dma_register_irq(irq, device);
        }

        //unmap registers
        iounmap(device->reg_virt_addr);
    }

    //zero out devices array
    kfree(devices);
    devices = NULL;
    num_devices = 0;
}
