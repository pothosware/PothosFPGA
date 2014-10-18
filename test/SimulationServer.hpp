// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <Pothos/Framework.hpp>
#include <mutex>
#include <map>

class SimulationHarness : public Pothos::Block
{
public:
    SimulationHarness(void);

    void work(void);

    void setupInput(const int index);
    bool inputHasData(const int index);
    int inputFrontData(const int index);
    void inputPopData(const int index);

    void setupOutput(const int index);
    bool outputHasSpace(const int index);
    void outputPushData(const int index, const int data);

private:
    std::map<int, Pothos::BufferChunk> _inputBuffers;
    std::map<int, Pothos::BufferChunk> _outputBuffers;
    std::mutex _mutex;
};
