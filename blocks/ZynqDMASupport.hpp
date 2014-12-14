// Copyright (c) 2013-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <Pothos/Framework.hpp>
#include "pothos_zynq_dma_user_driver.h"

//! Factory for Zynq DMA buffer manager
Pothos::BufferManager::Sptr makeZynqDMABufferManager(pzdud_t *engine, const pzdud_dir_t dir);
