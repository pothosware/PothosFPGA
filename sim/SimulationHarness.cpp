// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Framework.hpp>
#include <Poco/SingletonHolder.h>
#include <memory>
#include <mutex>
#include <condition_variable>
#include <thread>
#include <queue>
#include <map>
#include <iostream>

/***********************************************************************
 * The simulation source moves simulation data into the topology
 **********************************************************************/
class SimulationSource : public Pothos::Block
{
public:

    SimulationSource(void)
    {
        this->setupOutput(0, typeid(int));
    }

    void work(void)
    {
        auto outputPort = this->output(0);
        std::unique_lock<std::mutex> lock(_mutex);
        if (not _queue.empty())
        {
            auto buff = outputPort->buffer().as<int *>();
            const auto num = std::min(_queue.size(), outputPort->elements());
            for (size_t i = 0; i < num; i++)
            {
                buff[i] = _queue.front();
                _queue.pop();
            }
            outputPort->produce(num);
        }
        else
        {
            _cond.wait_for(lock, std::chrono::nanoseconds(this->workInfo().maxTimeoutNs));
            return this->yield();
        }
    }

    bool hasSpace(void)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        //TODO EOP condition in the future...
        return _queue.size()*sizeof(int) < 1024;
    }

    void pushData(const int data)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        _queue.push(data);
        _cond.notify_one();
    }

private:
    std::queue<int> _queue;
    std::condition_variable _cond;
    std::mutex _mutex;
};

static std::mutex &getSourceMutex(void)
{
    static Poco::SingletonHolder<std::mutex> sh;
    return *sh.get();
}

static std::map<int, std::shared_ptr<SimulationSource>> &getSimSources(void)
{
    static Poco::SingletonHolder<std::map<int, std::shared_ptr<SimulationSource>>> sh;
    return *sh.get();
}

/***********************************************************************
 * The simulation sink moves topology data into the simulation
 **********************************************************************/
class SimulationSink : public Pothos::Block
{
public:

    SimulationSink(void)
    {
        this->setupInput(0, typeid(int));
    }

    void work(void)
    {
        auto inputPort = this->input(0);
        std::unique_lock<std::mutex> lock(_mutex);
        if (_queue.empty())
        {
            auto buff = inputPort->buffer().as<const int *>();
            const auto num = inputPort->elements();
            for (size_t i = 0; i < num; i++)
            {
                _queue.push(buff[i]);
            }
            inputPort->consume(num);
        }
        else
        {
            _cond.wait_for(lock, std::chrono::nanoseconds(this->workInfo().maxTimeoutNs));
            return this->yield();
        }
    }

    bool hasData(void)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        return not _queue.empty();
    }

    void popData(void)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        _queue.pop();
        _cond.notify_one();
    }

    int frontData(void)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        if (_queue.empty()) return 0;
        return _queue.front();
    }

private:
    std::queue<int> _queue;
    std::condition_variable _cond;
    std::mutex _mutex;
};

static std::mutex &getSinkMutex(void)
{
    static Poco::SingletonHolder<std::mutex> sh;
    return *sh.get();
}

static std::map<int, std::shared_ptr<SimulationSink>> &getSimSinks(void)
{
    static Poco::SingletonHolder<std::map<int, std::shared_ptr<SimulationSink>>> sh;
    return *sh.get();
}

/***********************************************************************
 * The simulation control interfaces with address and data buses
 **********************************************************************/
class SimulationControl
{
public:
    SimulationControl(void):
        _action(0),
        _addr(0),
        _data(0)
    {
        return;
    }

    /*******************************************************************
     * host calls
     ******************************************************************/
    void write(const int addr, const int data)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        _action = 1;
        _addr = addr;
        _data = data;
        while (_action != 0) _cond.wait(lock);
    }

    int read(const int addr)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        _action = 2;
        _addr = addr;
        while (_action != 0) _cond.wait(lock);
        return _data;
    }

    /*******************************************************************
     * vhdl calls
     ******************************************************************/
    int getAction(void)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        return _action;
    }

    int getAddr(void)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        return _addr;
    }

    int getData(void)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        return _data;
    }

    void putData(const int data)
    {
        std::unique_lock<std::mutex> lock(_mutex);
        _data = data;
        _action = 0;
        lock.unlock();
        _cond.notify_one();
    }

private:
    int _action;
    int _addr;
    int _data;

    std::condition_variable _cond;
    std::mutex _mutex;
};

static std::mutex &getControlMutex(void)
{
    static Poco::SingletonHolder<std::mutex> sh;
    return *sh.get();
}

static std::map<int, std::shared_ptr<SimulationControl>> &getSimControls(void)
{
    static Poco::SingletonHolder<std::map<int, std::shared_ptr<SimulationControl>>> sh;
    return *sh.get();
}

/***********************************************************************
 * Proxy server background thread
 **********************************************************************/
void runProxyServer(void);

struct MyProxyServerRunner
{
    MyProxyServerRunner(void)
    {
        _thread = std::thread(&runProxyServer);
    }

    ~MyProxyServerRunner(void)
    {
        _thread.join();
    }

    std::thread _thread;
};

static MyProxyServerRunner &getMyProxyServerRunner(void)
{
    static Poco::SingletonHolder<MyProxyServerRunner> sh;
    return *sh.get();
}

/***********************************************************************
 * VHDL C foreign interface
 **********************************************************************/
#define EXPORT_TO_VHDL extern "C" POTHOS_HELPER_DLL_EXPORT

EXPORT_TO_VHDL void PothosFPGA_initProxyServer(int)
{
    getMyProxyServerRunner(); //one time init of server
}

EXPORT_TO_VHDL int PothosFPGA_setupSource(const int portIndex)
{
    std::unique_lock<std::mutex> lock(getSinkMutex());
    getSimSinks()[portIndex].reset(new SimulationSink());
    return portIndex;
}

EXPORT_TO_VHDL bool PothosFPGA_sourceHasData(const int handle)
{
    std::unique_lock<std::mutex> lock(getSinkMutex());
    return getSimSinks().at(handle)->hasData();
}

EXPORT_TO_VHDL void PothosFPGA_sourcePopData(const int handle)
{
    std::unique_lock<std::mutex> lock(getSinkMutex());
    return getSimSinks().at(handle)->popData();
}

EXPORT_TO_VHDL int PothosFPGA_sourceFrontData(const int handle)
{
    std::unique_lock<std::mutex> lock(getSinkMutex());
    return getSimSinks().at(handle)->frontData();
}

EXPORT_TO_VHDL int PothosFPGA_setupSink(const unsigned portIndex)
{
    std::unique_lock<std::mutex> lock(getSourceMutex());
    getSimSources()[portIndex].reset(new SimulationSource());
    return portIndex;
}

EXPORT_TO_VHDL bool PothosFPGA_sinkHasSpace(const int handle)
{
    std::unique_lock<std::mutex> lock(getSourceMutex());
    return getSimSources().at(handle)->hasSpace();
}

EXPORT_TO_VHDL void PothosFPGA_sinkPushData(const int handle, const int data)
{
    std::unique_lock<std::mutex> lock(getSourceMutex());
    return getSimSources().at(handle)->pushData(data);
}

EXPORT_TO_VHDL int PothosFPGA_setupControl(const int id)
{
    std::unique_lock<std::mutex> lock(getControlMutex());
    getSimControls()[id].reset(new SimulationControl());
    return id;
}

EXPORT_TO_VHDL int PothosFPGA_controlGetAction(const int handle)
{
    std::unique_lock<std::mutex> lock(getControlMutex());
    return getSimControls().at(handle)->getAction();
}

EXPORT_TO_VHDL int PothosFPGA_controlGetAddr(const int handle)
{
    std::unique_lock<std::mutex> lock(getControlMutex());
    return getSimControls().at(handle)->getAddr();
}

EXPORT_TO_VHDL int PothosFPGA_controlGetData(const int handle)
{
    std::unique_lock<std::mutex> lock(getControlMutex());
    return getSimControls().at(handle)->getData();
}

EXPORT_TO_VHDL void PothosFPGA_controlPutData(const int handle, const int data)
{
    std::unique_lock<std::mutex> lock(getControlMutex());
    return getSimControls().at(handle)->putData(data);
}

/***********************************************************************
 * Registered interface
 **********************************************************************/
struct SimulationHarness
{
    static std::shared_ptr<Pothos::Block> getSourceBlock(const int which)
    {
        std::unique_lock<std::mutex> lock(getSourceMutex());
        return getSimSources().at(which);
    }

    static std::shared_ptr<Pothos::Block> getSinkBlock(const int which)
    {
        std::unique_lock<std::mutex> lock(getSinkMutex());
        return getSimSinks().at(which);
    }

    static void writeControl(const int which, const int addr, const int data)
    {
        //std::unique_lock<std::mutex> lock(getControlMutex());
        return getSimControls().at(which)->write(addr, data);
    }

    static int readControl(const int which, const int addr)
    {
        //std::unique_lock<std::mutex> lock(getControlMutex());
        return getSimControls().at(which)->read(addr);
    }

    static std::vector<int> getSourceIndexes(void)
    {
        std::unique_lock<std::mutex> lock(getSourceMutex());
        std::vector<int> indexes;
        for (const auto &pair : getSimSources()) indexes.push_back(pair.first);
        return indexes;
    }

    static std::vector<int> getSinkIndexes(void)
    {
        std::unique_lock<std::mutex> lock(getSinkMutex());
        std::vector<int> indexes;
        for (const auto &pair : getSimSinks()) indexes.push_back(pair.first);
        return indexes;
    }

    static std::vector<int> getControlIndexes(void)
    {
        std::unique_lock<std::mutex> lock(getControlMutex());
        std::vector<int> indexes;
        for (const auto &pair : getSimControls()) indexes.push_back(pair.first);
        return indexes;
    }
};

#include <Pothos/Managed.hpp>

static auto managedSimulationHarness = Pothos::ManagedClass()
    .registerClass<SimulationHarness>()
    .registerStaticMethod(POTHOS_FCN_TUPLE(SimulationHarness, getSourceBlock))
    .registerStaticMethod(POTHOS_FCN_TUPLE(SimulationHarness, getSinkBlock))
    .registerStaticMethod(POTHOS_FCN_TUPLE(SimulationHarness, writeControl))
    .registerStaticMethod(POTHOS_FCN_TUPLE(SimulationHarness, readControl))
    .registerStaticMethod(POTHOS_FCN_TUPLE(SimulationHarness, getSourceIndexes))
    .registerStaticMethod(POTHOS_FCN_TUPLE(SimulationHarness, getSinkIndexes))
    .registerStaticMethod(POTHOS_FCN_TUPLE(SimulationHarness, getControlIndexes))
    .commit("Pothos/FPGA/SimulationHarness");
