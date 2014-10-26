// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/Testing.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/JSON/Object.h>
#include <iostream>
#include <cstdlib>

static const int IC_NUM_LANES_ADDR = 6;
static const int IC_NUM_INPUTS_ADDR = 7;
static const int IC_NUM_OUTPUTS_ADDR = 8;
static const int IC_TEST_LOOPBACK_ADDR = 9;
static const int IC_LANE_SELECT_ADDR = 10;
static const int IC_INPUT_SELECT_ADDR = 11;
static const int IC_LANE_DEST_MASK_ADDR = 12;
static const int IC_OUTPUT_DEST_MASK_ADDR = 13;

POTHOS_TEST_BLOCK("/fpga/tests", test_interconnect)
{
    //create client environment
    auto env = getSimulationEnv("InterconnectTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    //test the control bus
    for (size_t ntrial = 0; ntrial < 10; ntrial++)
    {
        const int randNum = std::rand();
        SimulationHarness.callVoid("writeControl", 0, IC_TEST_LOOPBACK_ADDR, randNum);
        POTHOS_TEST_EQUAL(SimulationHarness.call<int>("readControl", 0, IC_TEST_LOOPBACK_ADDR), randNum);

        POTHOS_TEST_EQUAL(2, SimulationHarness.call<int>("readControl", 0, IC_NUM_LANES_ADDR));

        auto sourceIndexes = SimulationHarness.call<std::vector<int>>("getSourceIndexes");
        POTHOS_TEST_EQUAL(sourceIndexes.size(), SimulationHarness.call<size_t>("readControl", 0, IC_NUM_OUTPUTS_ADDR));

        auto sinkIndexes = SimulationHarness.call<std::vector<int>>("getSinkIndexes");
        POTHOS_TEST_EQUAL(sinkIndexes.size(), SimulationHarness.call<size_t>("readControl", 0, IC_NUM_INPUTS_ADDR));
    }

}
