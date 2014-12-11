// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_axis_dma_module.h"
#include <linux/module.h> //module registration
#include <linux/device.h> //class/device calls
#include <linux/cdev.h> //character device
#include <linux/fs.h> //file_operations

/***********************************************************************
 * global variables for device registration
 **********************************************************************/
static dev_t dev_num = 0; // Global variable for the device number
static struct cdev c_dev; // Global variable for the character device structure
static struct class *cl = NULL; // Global variable for the device class
static struct file_operations fops = {
    poll: pothos_axis_dma_poll,
    unlocked_ioctl: pothos_axis_dma_ioctl,
    mmap: pothos_axis_dma_mmap,
    open: pothos_axis_dma_open,
    release: pothos_axis_dma_release
};

/***********************************************************************
 * Initialization and cleanup hooks for the module.
 * Below is pretty much standard boiler-plate
 * to make a device node appear in /dev/MODULE_NAME
 **********************************************************************/
static int pothos_axis_dma_init(void)
{
    printk(KERN_INFO MODULE_NAME " init: registering\n");

    pothos_axis_dma_probe();

    if (alloc_chrdev_region(&dev_num, 0, 1, MODULE_NAME) < 0)
    {
        return -1;
    }
    if ((cl = class_create(THIS_MODULE, MODULE_NAME)) == NULL)
    {
        unregister_chrdev_region(dev_num, 1);
        return -1;
    }
    if (device_create(cl, NULL, dev_num, NULL, MODULE_NAME) == NULL)
    {
        class_destroy(cl);
        unregister_chrdev_region(dev_num, 1);
        return -1;
    }
    cdev_init(&c_dev, &fops);
    if (cdev_add(&c_dev, dev_num, 1) == -1)
    {
        device_destroy(cl, dev_num);
        class_destroy(cl);
        unregister_chrdev_region(dev_num, 1);
        return -1;
    }
    printk(KERN_INFO MODULE_NAME " init: registered\n");
    return 0;
}

static void pothos_axis_dma_exit(void)
{
    cdev_del(&c_dev);
    device_destroy(cl, dev_num);
    class_destroy(cl);
    unregister_chrdev_region(dev_num, 1);
    pothos_axis_dma_unprobe();
    printk(KERN_INFO MODULE_NAME " exit: unregistered\n");
}

/***********************************************************************
 * register module
 **********************************************************************/
MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Josh Blum");
MODULE_DESCRIPTION("Pothos AXI DMA");
module_init(pothos_axis_dma_init);
module_exit(pothos_axis_dma_exit);
