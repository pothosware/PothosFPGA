// Copyright (c) 2013-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "ZynqDMASupport.hpp"

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
        if (_engine == nullptr) throw Pothos::Exception("ZyncDMASink::pzdud_create()");
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
            return makeZynqDMABufferManager(_engine, PZDUD_MM2S);
        }
        throw Pothos::PortDomainError();
    }

    void activate(void)
    {
        int ret = pzdud_init(_engine, PZDUD_MM2S);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZyncDMASink::pzdud_init()", std::to_string(ret));
    }

    void deactivate(void)
    {
        int ret = pzdud_halt(_engine, PZDUD_MM2S);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZyncDMASink::pzdud_halt()", std::to_string(ret));
    }

    void work(void)
    {
        auto inPort = this->input(0);

        //we have an input buffer:
        //stash it to perform wait for completion
        //consume it from the input port
        if (inPort->elements() != 0)
        {
            auto buff = inPort->buffer().getManagedBuffer();
            _buffsToWaitOn[buff.getSlabIndex()] = buff;
            inPort->consume(inPort->elements());
        }

        //
        //TODO this *below* isnt going to work for out of order buffers arriving here...
        //

        //wait for completion on the head buffer
        const long timeout_us = this->workInfo().maxTimeoutNs/1000;
        const int ret = pzdud_wait(_engine, PZDUD_MM2S, timeout_us);
        if (ret == PZDUD_ERROR_TIMEOUT)
        {
            //got a timeout, yield so we can get called again
            return this->yield();
        }

        //some other kind of error from wait occurred:
        else if (ret != PZDUD_OK)
        {
            throw Pothos::Exception("ZyncDMASink::pzdud_wait()", std::to_string(ret));
        }

        //acquire the head buffer and release its handle
        size_t length = 0; //length not used for MM2S
        const int handle = pzdud_acquire(_engine, PZDUD_MM2S, &length);
        if (handle >= 0) _buffsToWaitOn[handle] = Pothos::ManagedBuffer();
    }

private:
    pzdud_t *_engine;
    std::vector<Pothos::ManagedBuffer> _buffsToWaitOn;
};
