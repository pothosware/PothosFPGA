// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <linux/poll.h> //poll arguments

//! The name of this module used in printk
#define MODULE_NAME "pothos_axis_dma"

//! The poll implementation used to wait on interrupts
unsigned int pothos_axis_dma_poll(struct file *filp, struct poll_table_struct *wait);
