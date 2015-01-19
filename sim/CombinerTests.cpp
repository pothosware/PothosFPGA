// Copyright (c) 2014-2015 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/Testing.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/JSON/Object.h>
#include <iostream>

POTHOS_TEST_BLOCK("/fpga/tests", test_combiner_1x)
{
    //create client environment
    auto env = getSimulationEnv("CombinerTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

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
        POTHOS_TEST_TRUE(topology.waitInactive(1.0, 0.0));
    }

    collector.callVoid("verifyTestPlan", expected);
}

POTHOS_TEST_BLOCK("/fpga/tests", test_packet_combiner_1x)
{
    //create client environment
    auto env = getSimulationEnv("CombinerTb");
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
        POTHOS_TEST_TRUE(topology.waitInactive(1.0, 0.0));
    }

    collector.callVoid("verifyTestPlan", expected);

    //check that we have the expected packets
    checkPacketCollectors(packetsIn, packetsOut);
}

POTHOS_TEST_BLOCK("/fpga/tests", test_combiner_2x)
{
    //create client environment
    auto env = getSimulationEnv("CombinerTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    auto source1 = SimulationHarness.callProxy("getSourceBlock", 1);
    auto sink1 = SimulationHarness.callProxy("getSinkBlock", 1);
    auto sink2 = SimulationHarness.callProxy("getSinkBlock", 2);

    for (size_t i = 0; i < 2; i++)
    {
        std::cout << "testing combiner @ " << i << std::endl;

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
            topology.connect(feeder, 0, (i==0)?sink1:sink2, 0);
            topology.connect(source1, 0, collector, 0);
            topology.commit();
            POTHOS_TEST_TRUE(topology.waitInactive(1.0, 0.0));
        }

        collector.callVoid("verifyTestPlan", expected);
    }
}

POTHOS_TEST_BLOCK("/fpga/tests", test_packet_combiner_2x)
{
    //create client environment
    auto env = getSimulationEnv("CombinerTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    auto source1 = SimulationHarness.callProxy("getSourceBlock", 1);
    auto sink1 = SimulationHarness.callProxy("getSinkBlock", 1);
    auto sink2 = SimulationHarness.callProxy("getSinkBlock", 2);

    for (size_t i = 0; i < 2; i++)
    {
        std::cout << "testing combiner @ " << i << std::endl;

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
            auto sink = (i==0)?sink1:sink2;
            topology.connect(feeder, 0, s2p, 0);
            topology.connect(s2p, 0, packetsIn, 0);
            topology.connect(s2p, 0, sink, 0);

            topology.connect(source1, 0, p2s, 0);
            topology.connect(source1, 0, packetsOut, 0);
            topology.connect(p2s, 0, collector, 0);
            topology.commit();
            POTHOS_TEST_TRUE(topology.waitInactive(1.0, 0.0));
        }

        collector.callVoid("verifyTestPlan", expected);

        //check that we have the expected packets
        checkPacketCollectors(packetsIn, packetsOut);
    }
}
