// Copyright (c) 2013-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "ZynqDMASupport.hpp"
#include <Pothos/Util/RingDeque.hpp>
#include "pothos_zynq_dma_user_driver.h"
#include <memory>

template <pzdud_dir_t dir>
class ZynqDMABufferManager :
    public Pothos::BufferManager,
    public std::enable_shared_from_this<ZynqDMABufferManager<dir>>
{
public:
    ZynqDMABufferManager(pzdud_t *engine):
        _engine(engine)
    {
        return;
    }

    ~ZynqDMABufferManager(void)
    {
        if (this->isInitialized())
        {
            pzdud_free(_engine, dir);
        }
    }

    void init(const Pothos::BufferManagerArgs &args)
    {
        Pothos::BufferManager::init(args);
        _readyBuffs.set_capacity(args.numBuffers);
        int ret = pzdud_alloc(_engine, dir, args.numBuffers, args.bufferSize);
        if (ret != PZDUD_OK) throw Pothos::Exception("ZynqBufferManager::pzdud_alloc()", std::to_string(ret));

        //create all the buffer containers...
        for (size_t handle = 0; handle < args.numBuffers; handle++)
        {
            auto container = std::make_shared<int>(0);
            void *addr = pzdud_addr(_engine, dir, handle);
            auto sharedBuff = Pothos::SharedBuffer(size_t(addr), args.bufferSize, container);
            Pothos::ManagedBuffer buffer;
            buffer.reset(this->shared_from_this(), sharedBuff);
        }

        //FIXME for PZDUD_S2MM, this causes a second release call on all buffers...
    }

    bool empty(void) const
    {
        return _readyBuffs.empty();
    }

    void pop(const size_t numBytes)
    {
        //boiler-plate to pop from the queue and set the front buffer
        assert(not _readyBuffs.empty());
        auto buff = _readyBuffs.front();
        _readyBuffs.pop_front();
        if (_readyBuffs.empty()) this->setFrontBuffer(Pothos::BufferChunk::null());
        else this->setFrontBuffer(_readyBuffs.front());

        //pop == release in the dma to stream direction
        if (dir == PZDUD_MM2S)
        {
            pzdud_release(_engine, dir, buff.getSlabIndex(), numBytes);
        }
    }

    void push(const Pothos::ManagedBuffer &buff)
    {
        //boiler-plate to push into the queue and set the front buffer
        if (_readyBuffs.empty()) this->setFrontBuffer(buff);
        assert(not _readyBuffs.full());
        _readyBuffs.push_back(buff);

        //push == release in the stream to DMA direction
        if (dir == PZDUD_S2MM)
        {
            pzdud_release(_engine, dir, buff.getSlabIndex(), 0/*used param for s2mm*/);
        }
    }

private:
    Pothos::Util::RingDeque<Pothos::ManagedBuffer> _readyBuffs;
    pzdud_t *_engine;
};


Pothos::BufferManager::Sptr makeZynqDMABufferManager(pzdud_t *engine, const pzdud_dir_t dir)
{
    if (dir == PZDUD_S2MM) return Pothos::BufferManager::Sptr(new ZynqDMABufferManager<PZDUD_S2MM>(engine));
    if (dir == PZDUD_MM2S) return Pothos::BufferManager::Sptr(new ZynqDMABufferManager<PZDUD_MM2S>(engine));
    return Pothos::BufferManager::Sptr();
}
