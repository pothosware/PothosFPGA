// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_zynq_dma_module.h"
#include <linux/dma-mapping.h>
#include <linux/platform_device.h>

long pothos_zynq_dma_buffs_alloc(pothos_zynq_dma_device_t *data, const pothos_zynq_dma_alloc_t *user_config)
{
    struct platform_device *pdev = data->pdev;

    //are we already allocated?
    if (data->dma_buffs != NULL) return -EBUSY;

    //copy the buffer into kernel space
    pothos_zynq_dma_alloc_t alloc_args;
    if (copy_from_user(&alloc_args, user_config, sizeof(pothos_zynq_dma_alloc_t)) != 0)
    {
        return -EACCES;
    }

    //check the sentinel
    if (alloc_args.sentinel != POTHOS_ZYNQ_DMA_SENTINEL) return -EINVAL;

    //copy the dma buffers array into kernel space
    data->num_dma_buffs = alloc_args.num_buffs;
    data->dma_buffs = devm_kzalloc(&pdev->dev, alloc_args.num_buffs*sizeof(pothos_zynq_dma_buff_t), GFP_KERNEL);
    if (copy_from_user(data->dma_buffs, alloc_args.buffs, alloc_args.num_buffs*sizeof(pothos_zynq_dma_buff_t)) != 0)
    {
        return -EACCES;
    }

    //allocate dma buffers
    for (size_t i = 0; i < data->num_dma_buffs; i++)
    {
        dma_addr_t phys_addr = 0;
        size_t size = data->dma_buffs[i].bytes;
        void *virt_addr = dma_zalloc_coherent(&pdev->dev, size, &phys_addr, GFP_KERNEL);
        data->dma_buffs[i].paddr = phys_addr;
        data->dma_buffs[i].kaddr = virt_addr;
        data->dma_buffs[i].uaddr = NULL; //filled by user with mmap
    }

    //copy the allocation results back to the user ioctl buffer
    if (copy_to_user(alloc_args.buffs, data->dma_buffs, alloc_args.num_buffs*sizeof(pothos_zynq_dma_buff_t)) != 0)
    {
        return -EACCES;
    }

    return 0;
}

long pothos_zynq_dma_buffs_free(pothos_zynq_dma_device_t *data)
{
    struct platform_device *pdev = data->pdev;

    //already freed earlier
    if (data->dma_buffs == NULL) return 0;

    //free dma buffers
    for (size_t i = 0; i < data->num_dma_buffs; i++)
    {
        if (data->dma_buffs[i].kaddr == NULL) continue; //alloc failed eariler
        dma_free_coherent(&pdev->dev, data->dma_buffs[i].bytes, data->dma_buffs[i].kaddr, data->dma_buffs[i].paddr);
    }

    //free the dma buffer structures
    devm_kfree(&pdev->dev, data->dma_buffs);

    //clear
    data->num_dma_buffs = 0;
    data->dma_buffs = NULL;
    return 0;
}
