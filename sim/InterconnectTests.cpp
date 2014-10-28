// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/Testing.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/JSON/Object.h>
#include <iostream>
#include <cstdlib>

static const int IC_VERSION = 1;
static const int IC_VERSION_ADDR = 5;
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
    auto registry = env->findProxy("Pothos/BlockRegistry");

    //test the control bus
    POTHOS_TEST_EQUAL(IC_VERSION, SimulationHarness.call<int>("readControl", 0, IC_VERSION_ADDR));

    const int randNum = std::rand();
    SimulationHarness.callVoid("writeControl", 0, IC_TEST_LOOPBACK_ADDR, randNum);
    POTHOS_TEST_EQUAL(SimulationHarness.call<int>("readControl", 0, IC_TEST_LOOPBACK_ADDR), randNum);

    const auto numLanes = SimulationHarness.call<size_t>("readControl", 0, IC_NUM_LANES_ADDR);
    POTHOS_TEST_TRUE(numLanes > 0);
    POTHOS_TEST_TRUE(numLanes <= 32);

    const auto numOutputs = SimulationHarness.call<size_t>("readControl", 0, IC_NUM_OUTPUTS_ADDR);
    auto sourceIndexes = SimulationHarness.call<std::vector<int>>("getSourceIndexes");
    POTHOS_TEST_EQUAL(sourceIndexes.size(), numOutputs);

    const auto numInputs = SimulationHarness.call<size_t>("readControl", 0, IC_NUM_INPUTS_ADDR);
    auto sinkIndexes = SimulationHarness.call<std::vector<int>>("getSinkIndexes");
    POTHOS_TEST_EQUAL(sinkIndexes.size(), numInputs);

    //for each input port, for each output port, for each lane -- comms test
    for (size_t input_i = 0; input_i < numInputs; input_i++){
    for (size_t output_i = 0; output_i < numOutputs; output_i++){
    for (size_t lane_i = 0; lane_i < numLanes; lane_i++){

        std::cout << "Peform test: input " << input_i << " to ouput " << output_i << " on lane " << lane_i << std::endl;

        //program each input port
        for (size_t progInput_i = 0; progInput_i < numInputs; progInput_i++)
        {
            //program the lane destinations
            SimulationHarness.callVoid("writeControl", 0, IC_INPUT_SELECT_ADDR, progInput_i);
            const int laneMask = (progInput_i == input_i)? (1 << lane_i) : 0;
            SimulationHarness.callVoid("writeControl", 0, IC_LANE_DEST_MASK_ADDR, laneMask);

            //program the output destinations for each lane
            for (size_t progLane_i = 0; progLane_i < numLanes; progLane_i++)
            {
                SimulationHarness.callVoid("writeControl", 0, IC_LANE_SELECT_ADDR, progLane_i);
                const int outputMask = (progLane_i == lane_i)? (1 << output_i) : 0;
                SimulationHarness.callVoid("writeControl", 0, IC_OUTPUT_DEST_MASK_ADDR, outputMask);
            }
        }

        //create feeders and collectors for each port
        Pothos::Topology topology;
        Pothos::Proxy expected;
        std::vector<Pothos::Proxy> collectors;

        for (size_t progInput_i = 0; progInput_i < numInputs; progInput_i++)
        {
            //std::cout << "create feeder for input " << progInput_i << std::endl;
            auto feeder = registry.callProxy("/blocks/feeder_source", "int");
            Poco::JSON::Object::Ptr testPlan(new Poco::JSON::Object());
            testPlan->set("enableBuffers", true);
            auto expected_i = feeder.callProxy("feedTestPlan", testPlan);
            if (input_i == progInput_i) expected = expected_i;
            topology.connect(feeder, 0, SimulationHarness.callProxy("getSinkBlock", progInput_i), 0);
        }

        for (size_t progOutput_i = 0; progOutput_i < numOutputs; progOutput_i++)
        {
            //std::cout << "create collector for output " << progOutput_i << std::endl;
            auto collector = registry.callProxy("/blocks/collector_sink", "int");
            collectors.push_back(collector);
            topology.connect(SimulationHarness.callProxy("getSourceBlock", progOutput_i), 0, collector, 0);
        }

        topology.commit();
        POTHOS_TEST_TRUE(topology.waitInactive(0.5, 5.0));

        //check the collectors, the rest should be empty
        for (size_t progOutput_i = 0; progOutput_i < numOutputs; progOutput_i++)
        {
            if (progOutput_i == output_i) continue; //skip dest
            auto &collector = collectors.at(progOutput_i);
            auto buffer = collector.call<Pothos::BufferChunk>("getBuffer");
            POTHOS_TEST_EQUAL(buffer.length, 0);
        }

        //this collector should have the expected data
        collectors.at(output_i).callVoid("verifyTestPlan", expected);

    }}}

}
