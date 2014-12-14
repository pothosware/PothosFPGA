// Copyright (c) 2013-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Framework/BufferManager.hpp>
#include <Pothos/Exception.hpp>
#include <Pothos/Util/RingDeque.hpp>
#include "pothos_zynq_dma_user_driver.h"
#include <memory>

class ZynqMM2SBufferManager :
    public Pothos::BufferManager,
    public std::enable_shared_from_this<ZynqMM2SBufferManager>
{
public:
    ZynqMM2SBufferManager(pzdud_t *engine):
        _engine(engine)
    {
        return;
    }

    ~ZynqMM2SBufferManager(void)
    {
        if (this->isInitialized())
        {
            pzdud_free(_engine, PZDUD_MM2S);
        }
    }

    void init(const Pothos::BufferManagerArgs &args)
    {
        Pothos::BufferManager::init(args);
        _readyBuffs.set_capacity(args.numBuffers);
        int ret = pzdud_alloc(_engine, PZDUD_MM2S, args.numBuffers, args.bufferSize);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZynqBufferManager::pzdud_alloc()", std::to_string(ret));

        //acquire all buffers from the engine and attach them to ManagedBuffers
    }

    bool empty(void) const
    {
        return _readyBuffs.empty();
    }

    void pop(const size_t numBytes)
    {
        
    }

    void push(const Pothos::ManagedBuffer &buff)
    {
        
    }

private:
    Pothos::Util::RingDeque<Pothos::ManagedBuffer> _readyBuffs;
    pzdud_t *_engine;
};
