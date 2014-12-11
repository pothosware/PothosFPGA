// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "pothos_axis_dma.h"
#include <linux/interrupt.h> //irq registration
#include <linux/wait.h> //wait_queue_head_t
#include <linux/sched.h> //interruptable

static wait_queue_head_t wait_queue;

static irqreturn_t pothos_axis_dma_irq_handler(int irq, void *data)
{
    //TODO ack irq
    //hit wait queue
    wake_up_interruptible(&wait_queue);
    return IRQ_HANDLED;
}

unsigned int pothos_axis_dma_poll(struct file *filp, struct poll_table_struct *wait)
{
    poll_wait(filp, &wait_queue, wait);
    unsigned int mask = 0;
    return mask;
}
