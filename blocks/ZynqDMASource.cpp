// Copyright (c) 2013-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Framework.hpp>
#include "pothos_zynq_dma_user_driver.h"

/***********************************************************************
 * |PothosDoc Zynq DMA Source
 *
 * Test block for receiving DMA buffers from the PL.
 *
 * |category /Zynq
 * |category /Sources
 * |keywords zynq dma
 *
 * |param axiDMAIndex The index of an AXI DMA on the system
 * |default 0
 *
 * |factory /zynq/dma_source(axiDMAIndex)
 **********************************************************************/
class ZyncDMASource : public Pothos::Block
{
public:
    ZyncDMASource(const size_t axiDMAIndex):
        _engine(pzdud_create(axiDMAIndex))
    {
        if (_engine == nullptr) throw Pothos::Exception("ZynqBufferManager::pzdud_create()");
        this->setupOutput(0, "", "ZyncDMASource"+std::to_string(axiDMAIndex));
    }

    ~ZyncDMASource(void)
    {
        pzdud_destroy(_engine);
    }

    Pothos::BufferManager::Sptr getOutputBufferManager(const std::string &, const std::string &domain)
    {
        if (domain.empty())
        {
            //make buffer mgr...
        }
        throw Pothos::PortDomainError();
    }

    void activate(void)
    {
        int ret = pzdud_init(_engine, PZDUD_S2MM);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZynqBufferManager::pzdud_init()", std::to_string(ret));
    }

    void deactivate(void)
    {
        int ret = pzdud_halt(_engine, PZDUD_S2MM);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZynqBufferManager::pzdud_halt()", std::to_string(ret));
    }

    void work(void)
    {
        //the output buffer will be a DMA buff
        //wait on completion (max timeout)
        //aquire the buffer
        //produce

        //the push operation of the manager performs release
    }

private:
    pzdud_t *_engine;
};
