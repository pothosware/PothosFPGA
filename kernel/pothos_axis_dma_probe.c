// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_axis_dma.h"
#include <linux/of.h>
#include <linux/of_irq.h>

static pothos_axi_dma_device_t devices[8];
static size_t num_devices = 0;

void pothos_axis_dma_probe(void)
{
    num_devices = 0;

    struct device_node *node = NULL;

    for_each_compatible_node(node, NULL, "xlnx,axi-dma")
    {
        pothos_axi_dma_device_t *device = devices+num_devices;
        num_devices++;

        printk(KERN_INFO MODULE_NAME " probe: found %s\n", of_node_full_name(node));
        device->node = node;
        init_waitqueue_head(&device->irq_wait);

        for (size_t i = 0; (1); i++)
        {
            unsigned int irq = irq_of_parse_and_map(node, i);
            if (irq == 0) break;
            printk(KERN_INFO MODULE_NAME " probe: register IRQ %u\n", irq);
            int ret = pothos_axis_dma_register_irq(irq, device);
            if (ret != 0) printk(KERN_INFO MODULE_NAME " probe: register IRQ FAIL %d\n", ret);
        }

        //TODO
        u32 v0, v1;
        of_property_read_u32_index(node, "reg", 0, &v0);
        of_property_read_u32_index(node, "reg", 1, &v1);
        printk(KERN_INFO MODULE_NAME " reg is 0x%x 0x%x\n", v0, v1);
        u32 has = of_property_read_bool(node, "xlnx,include-sg");
        printk(KERN_INFO MODULE_NAME " has sg %d\n", has);
    }
}

void pothos_axis_dma_unprobe(void)
{
    for (size_t devno = 0; devno < num_devices; devno++)
    {
        pothos_axi_dma_device_t *device = devices+devno;
        for (size_t i = 0; (1); i++)
        {
            unsigned int irq = irq_of_parse_and_map(device->node, i);
            if (irq == 0) break;
            pothos_axis_dma_register_irq(irq, device);
        }
    }
}
