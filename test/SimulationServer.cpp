// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationServer.hpp"
#include <Poco/SingletonHolder.h>

/***********************************************************************
 * Simulation harness implementation
 **********************************************************************/
SimulationHarness::SimulationHarness(void)
{
    return;
}

void SimulationHarness::work(void)
{
    for (auto input : this->inputs())
    {
        std::unique_lock<std::mutex> lock(_mutex);
        if (_inputBuffers[input->index()].elements() != 0) continue;
        _inputBuffers[input->index()] = input->buffer();
        input->consume(input->elements());
    }
    for (auto output : this->outputs())
    {
        std::unique_lock<std::mutex> lock(_mutex);
        auto &buff = _outputBuffers.at(output->index());

        if (buff.elements() == 0)
        {
            buff = output->buffer();
            output->popBuffer(buff.length);
            buff.length = 0;
            continue;
        }

        if (buff.getEnd() < buff.getBuffer().getEnd()) continue;
        output->postBuffer(buff);
        buff = Pothos::BufferChunk();
    }
    return this->yield(); //call again
}

void SimulationHarness::setupInput(const int index)
{
    std::unique_lock<std::mutex> lock(_mutex);
    Pothos::Block::setupInput(index, typeid(int));
}

bool SimulationHarness::inputHasData(const int index)
{
    std::unique_lock<std::mutex> lock(_mutex);
    return _inputBuffers.at(index).elements() != 0;
}

int SimulationHarness::inputFrontData(const int index)
{
    std::unique_lock<std::mutex> lock(_mutex);
    return _inputBuffers.at(index).as<const int *>()[0];
}

void SimulationHarness::inputPopData(const int index)
{
    std::unique_lock<std::mutex> lock(_mutex);
    _inputBuffers.at(index).length -= sizeof(int);
    _inputBuffers.at(index).address += sizeof(int);
}

void SimulationHarness::setupOutput(const int index)
{
    std::unique_lock<std::mutex> lock(_mutex);
    Pothos::Block::setupOutput(index, typeid(int));
}

bool SimulationHarness::outputHasSpace(const int index)
{
    std::unique_lock<std::mutex> lock(_mutex);
    auto &buff = _outputBuffers.at(index);
    return buff.getEnd() < buff.getBuffer().getEnd();
}

void SimulationHarness::outputPushData(const int index, const int data)
{
    std::unique_lock<std::mutex> lock(_mutex);
    auto &buff = _outputBuffers.at(index);
    buff.as<int *>()[buff.elements()] = data;
    buff.length += sizeof(int);
}

static SimulationHarness &getSimulationHarness(void)
{
    static Poco::SingletonHolder<SimulationHarness> sh;
    return *sh.get();
}

/***********************************************************************
 * VHDL C foreign interface
 **********************************************************************/
#define EXPORT_TO_VHDL extern "C" POTHOS_HELPER_DLL_EXPORT

EXPORT_TO_VHDL int PothosFPGA_setupSource(const int portIndex)
{
    getSimulationHarness().setupInput(portIndex);
    return portIndex;
}

EXPORT_TO_VHDL bool PothosFPGA_sourceHasData(const int handle)
{
    return getSimulationHarness().inputHasData(handle);
}

EXPORT_TO_VHDL bool PothosFPGA_sourcePopData(const int handle)
{
    getSimulationHarness().inputPopData(handle);
    return true;
}

EXPORT_TO_VHDL int PothosFPGA_sourceFrontData(const int handle)
{
    return getSimulationHarness().inputFrontData(handle);
}

EXPORT_TO_VHDL int PothosFPGA_setupSink(const unsigned portIndex)
{
    getSimulationHarness().setupOutput(portIndex);
    return portIndex;
}

EXPORT_TO_VHDL bool PothosFPGA_sinkHasSpace(const int handle)
{
    return getSimulationHarness().outputHasSpace(handle);
}

EXPORT_TO_VHDL bool PothosFPGA_sinkPushData(const int handle, const int data)
{
    getSimulationHarness().outputPushData(handle, data);
    return true;
}
