// Copyright (c) 2013-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "ZynqDMASupport.hpp"

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
        if (_engine == nullptr) throw Pothos::Exception("ZyncDMASource::pzdud_create()");
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
            return makeZynqDMABufferManager(_engine, PZDUD_S2MM);
        }
        throw Pothos::PortDomainError();
    }

    void activate(void)
    {
        int ret = pzdud_init(_engine, PZDUD_S2MM);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZyncDMASource::pzdud_init()", std::to_string(ret));
    }

    void deactivate(void)
    {
        int ret = pzdud_halt(_engine, PZDUD_S2MM);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZyncDMASource::pzdud_halt()", std::to_string(ret));
    }

    void work(void)
    {
        auto outPort = this->output(0);

        //check if a buffer is available
        if (outPort->elements() == 0) return;

        //
        //TODO this *below* isnt going to work for out of order buffers arriving here...
        //

        //wait for completion on the head buffer
        const long timeout_us = this->workInfo().maxTimeoutNs/1000;
        const int ret = pzdud_wait(_engine, PZDUD_S2MM, timeout_us);
        if (ret == PZDUD_ERROR_TIMEOUT)
        {
            //got a timeout, yield so we can get called again
            return this->yield();
        }

        //some other kind of error from wait occurred:
        else if (ret != PZDUD_OK)
        {
            throw Pothos::Exception("ZyncDMASource::pzdud_wait()", std::to_string(ret));
        }

        //acquire the head buffer and release its handle
        size_t length = 0;
        const int handle = pzdud_acquire(_engine, PZDUD_S2MM, &length);
        if (handle >= 0) outPort->produce(length);
    }

private:
    pzdud_t *_engine;
};
