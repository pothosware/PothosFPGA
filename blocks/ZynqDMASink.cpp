// Copyright (c) 2013-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Framework.hpp>
#include "pothos_zynq_dma_user_driver.h"

/***********************************************************************
 * |PothosDoc Zynq DMA Sink
 *
 * Test block for sending DMA buffers into the PL.
 *
 * |category /Zynq
 * |category /Sinks
 * |keywords zynq dma
 *
 * |param axiDMAIndex The index of an AXI DMA on the system
 * |default 0
 *
 * |factory /zynq/dma_sink(axiDMAIndex)
 **********************************************************************/
class ZyncDMASink : public Pothos::Block
{
public:
    ZyncDMASink(const size_t axiDMAIndex):
        _engine(pzdud_create(axiDMAIndex))
    {
        if (_engine == nullptr) throw Pothos::Exception("ZynqBufferManager::pzdud_create()");
        this->setupInput(0, "", "ZyncDMASink"+std::to_string(axiDMAIndex));
    }

    ~ZyncDMASink(void)
    {
        pzdud_destroy(_engine);
    }

    Pothos::BufferManager::Sptr getInputBufferManager(const std::string &, const std::string &domain)
    {
        if (domain.empty())
        {
            //make buffer mgr...
        }
        throw Pothos::PortDomainError();
    }

    void activate(void)
    {
        int ret = pzdud_init(_engine, PZDUD_MM2S);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZynqBufferManager::pzdud_init()", std::to_string(ret));
    }

    void deactivate(void)
    {
        int ret = pzdud_halt(_engine, PZDUD_MM2S);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZynqBufferManager::pzdud_halt()", std::to_string(ret));
    }

    void work(void)
    {
        //the manager's pop should release the buffer (upstream)

        //the input buffer will be a DMA buff
        //we must consume it from the port

        //store the released buffer
        //wait on completion
        //aquire and deref it back to the upstream mgr
    }

private:
    pzdud_t *_engine;
};
