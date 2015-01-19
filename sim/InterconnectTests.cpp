// Copyright (c) 2014-2015 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/Testing.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/JSON/Object.h>
#include <iostream>
#include <cstdlib>

static const int IC_VERSION = 0x00010000;
static const int IC_VERSION_ADDR = 20;
static const int IC_NUM_LANES_ADDR = 24;
static const int IC_NUM_INPUTS_ADDR = 28;
static const int IC_NUM_OUTPUTS_ADDR = 32;
static const int IC_TEST_LOOPBACK_ADDR = 36;
static const int IC_LANE_SELECT_ADDR = 40;
static const int IC_INPUT_SELECT_ADDR = 44;
static const int IC_LANE_DEST_MASK_ADDR = 48;
static const int IC_OUTPUT_DEST_MASK_ADDR = 52;
static const int IC_OUTPUT_FLOW_MASK_ADDR = 56;

POTHOS_TEST_BLOCK("/fpga/tests", test_interconnect_121)
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
        POTHOS_TEST_TRUE(topology.waitInactive(1.0, 0.0));

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

POTHOS_TEST_BLOCK("/fpga/tests", test_interconnect_m2m)
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

    //create feeders and collectors for each port
    Pothos::Topology topology;
    std::vector<Pothos::Proxy> expected;
    std::vector<Pothos::Proxy> collectors;

    //create feeders for each input
    for (size_t i = 0; i < numInputs; i++)
    {
        auto feeder = registry.callProxy("/blocks/feeder_source", "int");
        Poco::JSON::Object::Ptr testPlan(new Poco::JSON::Object());
        testPlan->set("enableBuffers", true);
        expected.push_back(feeder.callProxy("feedTestPlan", testPlan));
        topology.connect(feeder, 0, SimulationHarness.callProxy("getSinkBlock", i), 0);
    }

    //create collectors for each output
    for (size_t i = 0; i < numOutputs; i++)
    {
        auto collector = registry.callProxy("/blocks/collector_sink", "int");
        collectors.push_back(collector);
        topology.connect(SimulationHarness.callProxy("getSourceBlock", i), 0, collector, 0);
    }

    //program each input port
    //each input port goes to an output of the same index if it exists
    for (size_t progInput_i = 0; progInput_i < numInputs; progInput_i++)
    {
        //program the lane destinations
        SimulationHarness.callVoid("writeControl", 0, IC_INPUT_SELECT_ADDR, progInput_i);
        const int laneMask = 1 << (progInput_i % numLanes); //pick a lane
        SimulationHarness.callVoid("writeControl", 0, IC_LANE_DEST_MASK_ADDR, laneMask);

        //program the output destinations for each lane
        for (size_t progLane_i = 0; progLane_i < numLanes; progLane_i++)
        {
            SimulationHarness.callVoid("writeControl", 0, IC_LANE_SELECT_ADDR, progLane_i);
            const int outputMask = (progInput_i < numOutputs)? (1 << progInput_i) : 0;
            SimulationHarness.callVoid("writeControl", 0, IC_OUTPUT_DEST_MASK_ADDR, outputMask);
        }
    }

    topology.commit();
    POTHOS_TEST_TRUE(topology.waitInactive(1.0, 0.0));

    for (size_t i = 0; i < numOutputs; i++)
    {
        std::cout << "verify output " << i << std::endl;
        auto &collector = collectors.at(i);
        if (i >= expected.size())
        {
            auto buffer = collector.call<Pothos::BufferChunk>("getBuffer");
            POTHOS_TEST_EQUAL(buffer.length, 0);
            std::cout << "empty OK" << std::endl;
        }
        else
        {
            //this collector should have the expected data
            collector.callVoid("verifyTestPlan", expected.at(i));
            std::cout << "test plan OK" << std::endl;
        }
    }
}

POTHOS_TEST_BLOCK("/fpga/tests", test_packet_interconnect_m2m)
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

    //create feeders and collectors for each port
    Pothos::Topology topology;
    std::vector<Pothos::Proxy> expected;
    std::vector<Pothos::Proxy> collectors;
    std::vector<Pothos::Proxy> packetsIns;
    std::vector<Pothos::Proxy> packetsOuts;

    //create feeders for each input
    for (size_t i = 0; i < numInputs; i++)
    {
        auto feeder = registry.callProxy("/blocks/feeder_source", "int");
        Poco::JSON::Object::Ptr testPlan(new Poco::JSON::Object());
        testPlan->set("enableBuffers", true);
        expected.push_back(feeder.callProxy("feedTestPlan", testPlan));

        auto packetsOut = registry.callProxy("/blocks/collector_sink", "int");
        packetsOuts.push_back(packetsOut);

        auto s2p = registry.callProxy("/blocks/stream_to_packet");
        s2p.callVoid("setMTU", 32); //small fragments

        topology.connect(feeder, 0, s2p, 0);
        topology.connect(s2p, 0, packetsOut, 0);
        topology.connect(s2p, 0, SimulationHarness.callProxy("getSinkBlock", i), 0);
    }

    //create collectors for each output
    for (size_t i = 0; i < numOutputs; i++)
    {
        auto collector = registry.callProxy("/blocks/collector_sink", "int");
        collectors.push_back(collector);

        auto p2s = registry.callProxy("/blocks/packet_to_stream");

        auto packetsIn = registry.callProxy("/blocks/collector_sink", "int");
        packetsIns.push_back(packetsIn);

        topology.connect(SimulationHarness.callProxy("getSourceBlock", i), 0, p2s, 0);
        topology.connect(SimulationHarness.callProxy("getSourceBlock", i), 0, packetsIn, 0);
        topology.connect(p2s, 0, collector, 0);
    }

    //program each input port
    //each input port goes to an output of the same index if it exists
    for (size_t progInput_i = 0; progInput_i < numInputs; progInput_i++)
    {
        //program the lane destinations
        SimulationHarness.callVoid("writeControl", 0, IC_INPUT_SELECT_ADDR, progInput_i);
        const int laneMask = 1 << (progInput_i % numLanes); //pick a lane
        SimulationHarness.callVoid("writeControl", 0, IC_LANE_DEST_MASK_ADDR, laneMask);

        //program the output destinations for each lane
        for (size_t progLane_i = 0; progLane_i < numLanes; progLane_i++)
        {
            SimulationHarness.callVoid("writeControl", 0, IC_LANE_SELECT_ADDR, progLane_i);
            const int outputMask = (progInput_i < numOutputs)? (1 << progInput_i) : 0;
            SimulationHarness.callVoid("writeControl", 0, IC_OUTPUT_DEST_MASK_ADDR, outputMask);
        }
    }

    topology.commit();
    POTHOS_TEST_TRUE(topology.waitInactive(1.0, 0.0));

    for (size_t i = 0; i < numOutputs; i++)
    {
        std::cout << "verify output " << i << std::endl;
        auto &collector = collectors.at(i);
        auto &packetsIn = packetsIns.at(i);
        auto &packetsOut = packetsOuts.at(i);
        if (i >= expected.size())
        {
            auto buffer = collector.call<Pothos::BufferChunk>("getBuffer");
            POTHOS_TEST_EQUAL(buffer.length, 0);
            std::cout << "empty OK" << std::endl;
        }
        else
        {
            //this collector should have the expected data
            collector.callVoid("verifyTestPlan", expected.at(i));
            std::cout << "test plan OK" << std::endl;

            //check that we have the expected packets
            checkPacketCollectors(packetsIn, packetsOut);
        }
    }
}
