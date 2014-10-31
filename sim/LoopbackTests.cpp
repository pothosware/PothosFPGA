// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/Testing.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/JSON/Object.h>
#include <iostream>

POTHOS_TEST_BLOCK("/fpga/tests", test_loopback)
{
    //create client environment
    auto env = getSimulationEnv("LoopbackTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    auto sourceIndexes = SimulationHarness.call<std::vector<int>>("getSourceIndexes");
    POTHOS_TEST_EQUAL(sourceIndexes.size(), 1);
    POTHOS_TEST_EQUAL(sourceIndexes[0], 0);

    auto sinkIndexes = SimulationHarness.call<std::vector<int>>("getSinkIndexes");
    POTHOS_TEST_EQUAL(sinkIndexes.size(), 1);
    POTHOS_TEST_EQUAL(sinkIndexes[0], 0);

    auto source0 = SimulationHarness.callProxy("getSourceBlock", 0);
    auto sink0 = SimulationHarness.callProxy("getSinkBlock", 0);

    auto registry = env->findProxy("Pothos/BlockRegistry");
    auto feeder = registry.callProxy("/blocks/feeder_source", "int");
    auto collector = registry.callProxy("/blocks/collector_sink", "int");

    //create a test plan
    Poco::JSON::Object::Ptr testPlan(new Poco::JSON::Object());
    testPlan->set("enableBuffers", true);
    auto expected = feeder.callProxy("feedTestPlan", testPlan);

    //run the topology
    {
        Pothos::Topology topology;
        topology.connect(feeder, 0, sink0, 0);
        topology.connect(source0, 0, collector, 0);
        topology.commit();
        POTHOS_TEST_TRUE(topology.waitInactive());
    }

    collector.callVoid("verifyTestPlan", expected);
}

POTHOS_TEST_BLOCK("/fpga/tests", test_packet_loopback)
{
    //create client environment
    auto env = getSimulationEnv("LoopbackTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    auto source0 = SimulationHarness.callProxy("getSourceBlock", 0);
    auto sink0 = SimulationHarness.callProxy("getSinkBlock", 0);

    auto registry = env->findProxy("Pothos/BlockRegistry");
    auto feeder = registry.callProxy("/blocks/feeder_source", "int");
    auto collector = registry.callProxy("/blocks/collector_sink", "int");
    auto packetsIn = registry.callProxy("/blocks/collector_sink", "int");
    auto packetsOut = registry.callProxy("/blocks/collector_sink", "int");

    auto s2p = registry.callProxy("/blocks/stream_to_packet");
    s2p.callVoid("setMTU", 32); //small fragments
    auto p2s = registry.callProxy("/blocks/packet_to_stream");

    //create a test plan
    Poco::JSON::Object::Ptr testPlan(new Poco::JSON::Object());
    testPlan->set("enableBuffers", true);
    auto expected = feeder.callProxy("feedTestPlan", testPlan);

    //run the topology
    {
        Pothos::Topology topology;

        topology.connect(feeder, 0, s2p, 0);
        topology.connect(s2p, 0, packetsIn, 0);
        topology.connect(s2p, 0, sink0, 0);

        topology.connect(source0, 0, p2s, 0);
        topology.connect(source0, 0, packetsOut, 0);
        topology.connect(p2s, 0, collector, 0);

        topology.commit();
        POTHOS_TEST_TRUE(topology.waitInactive());
    }

    collector.callVoid("verifyTestPlan", expected);

    //check that we have the expected packets
    checkPacketCollectors(packetsIn, packetsOut);
}

POTHOS_TEST_BLOCK("/fpga/tests", test_control)
{
    //create client environment
    auto env = getSimulationEnv("LoopbackTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    auto controlIndexes = SimulationHarness.call<std::vector<int>>("getControlIndexes");
    POTHOS_TEST_EQUAL(controlIndexes.size(), 1);
    POTHOS_TEST_EQUAL(controlIndexes[0], 0);

    const int numAddrs = 4;

    std::cout << "write the test ram..." << std::endl;
    for (int i = 0; i < numAddrs; i++)
    {
        SimulationHarness.callVoid("writeControl", 0, i, 10+i);
    }

    std::cout << "read the test ram..." << std::endl;
    for (int i = 0; i < numAddrs; i++)
    {
        POTHOS_TEST_EQUAL(SimulationHarness.call<int>("readControl", 0, i), 10+i);
    }
}
