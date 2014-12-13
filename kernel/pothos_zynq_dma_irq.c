// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_zynq_dma_module.h"
#include <linux/uaccess.h> //copy_to/from_user
#include <linux/interrupt.h> //irq registration
#include <linux/wait.h> //wait_queue_head_t
#include <linux/sched.h> //interruptible
#include <linux/io.h> //iowrite32

static irqreturn_t pothos_zynq_dma_irq_handler(int irq, void *data_)
{
    pothos_zynq_dma_device_t *data = (pothos_zynq_dma_device_t *)data_;

    //ack the interrupts from both channels regardless of which IRQ caused this interrupt
    iowrite32(XILINX_DMA_XR_IRQ_ALL_MASK, ((char *)data->regs_virt_addr) + XILINX_DMA_S2MM_DMASR_OFFSET);
    iowrite32(XILINX_DMA_XR_IRQ_ALL_MASK, ((char *)data->regs_virt_addr) + XILINX_DMA_MM2S_DMASR_OFFSET);

    //wake up any contexts which are blocking on the wait queue
    wake_up_interruptible(&data->irq_wait);

    return IRQ_HANDLED;
}

long pothos_zynq_dma_wait(pothos_zynq_dma_device_t *data, const pothos_zynq_dma_wait_t *user_config)
{
    //convert the args into kernel memory
    pothos_zynq_dma_wait_t wait_args;
    if (copy_from_user(&wait_args, user_config, sizeof(pothos_zynq_dma_wait_t)) != 0)
    {
        return -EACCES;
    }

    //check the sentinel
    if (wait_args.sentinel != POTHOS_ZYNQ_DMA_SENTINEL) return -EINVAL;

    //wait on the condition
    xilinx_dma_desc_t *desc = wait_args.sgtable;
    const unsigned long timeout = usecs_to_jiffies(wait_args.timeout_us);
    wait_event_interruptible_timeout(data->irq_wait, ((desc->status & (1 << 31)) != 0), timeout);
    return 0;
}

int pothos_zynq_dma_register_irq(unsigned int irq, pothos_zynq_dma_device_t *data)
{
    return 0;
    //return request_irq(irq, pothos_zynq_dma_irq_handler, IRQF_SHARED, "xilinx-dma-controller", data);
}

void pothos_zynq_dma_unregister_irq(unsigned int irq, pothos_zynq_dma_device_t *data)
{
    //return free_irq(irq, data);
}
