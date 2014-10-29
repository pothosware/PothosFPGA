// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/Testing.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/JSON/Object.h>
#include <iostream>

POTHOS_TEST_BLOCK("/fpga/tests", test_splitter_1x)
{
    //create client environment
    auto env = getSimulationEnv("SplitterTb");
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
        POTHOS_TEST_TRUE(topology.waitInactive());
    }

    collector.callVoid("verifyTestPlan", expected);
}

POTHOS_TEST_BLOCK("/fpga/tests", test_packet_splitter_1x)
{
    //create client environment
    auto env = getSimulationEnv("SplitterTb");
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
    const auto pktsIn = packetsIn.call<std::vector<Pothos::Object>>("getMessages");
    const auto pktsOut = packetsOut.call<std::vector<Pothos::Object>>("getMessages");
    POTHOS_TEST_EQUAL(pktsIn.size(), pktsOut.size());
    for (size_t i = 0; i < pktsIn.size(); i++)
    {
        auto pktIn = pktsIn.at(i).convert<Pothos::Packet>();
        auto pktOut = pktsOut.at(i).convert<Pothos::Packet>();
        POTHOS_TEST_TRUE(pktIn.payload.length == pktOut.payload.length);
        POTHOS_TEST_TRUE(pktIn.payload.dtype == pktOut.payload.dtype);
    }
}

POTHOS_TEST_BLOCK("/fpga/tests", test_splitter_2x)
{
    //create client environment
    auto env = getSimulationEnv("SplitterTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    auto controlIndexes = SimulationHarness.call<std::vector<int>>("getControlIndexes");
    POTHOS_TEST_EQUAL(controlIndexes.size(), 1);
    POTHOS_TEST_EQUAL(controlIndexes[0], 0);

    auto source1 = SimulationHarness.callProxy("getSourceBlock", 1);
    auto source2 = SimulationHarness.callProxy("getSourceBlock", 2);
    auto sink1 = SimulationHarness.callProxy("getSinkBlock", 1);

    for (int enables = 0; enables < 4; enables++)
    {
        std::cout << "testing splitter with enables = " << enables << std::endl;

        auto registry = env->findProxy("Pothos/BlockRegistry");
        auto feeder = registry.callProxy("/blocks/feeder_source", "int");
        auto collector0 = registry.callProxy("/blocks/collector_sink", "int");
        auto collector1 = registry.callProxy("/blocks/collector_sink", "int");

        //write the enables register at addr = 1
        SimulationHarness.callVoid("writeControl", 0, 1, enables);

        //create a test plan
        Poco::JSON::Object::Ptr testPlan(new Poco::JSON::Object());
        testPlan->set("enableBuffers", true);
        auto expected = feeder.callProxy("feedTestPlan", testPlan);

        //run the topology
        {
            Pothos::Topology topology;
            topology.connect(feeder, 0, sink1, 0);
            topology.connect(source1, 0, collector0, 0);
            topology.connect(source2, 0, collector1, 0);
            topology.commit();
            POTHOS_TEST_TRUE(topology.waitInactive());
        }

        if ((enables & 0x1) != 0) collector0.callVoid("verifyTestPlan", expected);
        if ((enables & 0x2) != 0) collector1.callVoid("verifyTestPlan", expected);
    }
}

POTHOS_TEST_BLOCK("/fpga/tests", test_packet_splitter_2x)
{
    //create client environment
    auto env = getSimulationEnv("SplitterTb");
    auto SimulationHarness = env->findProxy("Pothos/FPGA/SimulationHarness");

    auto controlIndexes = SimulationHarness.call<std::vector<int>>("getControlIndexes");
    POTHOS_TEST_EQUAL(controlIndexes.size(), 1);
    POTHOS_TEST_EQUAL(controlIndexes[0], 0);

    auto source1 = SimulationHarness.callProxy("getSourceBlock", 1);
    auto source2 = SimulationHarness.callProxy("getSourceBlock", 2);
    auto sink1 = SimulationHarness.callProxy("getSinkBlock", 1);

    for (int enables = 0; enables < 4; enables++)
    {
        std::cout << "testing splitter with enables = " << enables << std::endl;

        auto registry = env->findProxy("Pothos/BlockRegistry");
        auto feeder = registry.callProxy("/blocks/feeder_source", "int");
        auto collector0 = registry.callProxy("/blocks/collector_sink", "int");
        auto collector1 = registry.callProxy("/blocks/collector_sink", "int");
        auto packetsIn = registry.callProxy("/blocks/collector_sink", "int");
        auto packetsOut0 = registry.callProxy("/blocks/collector_sink", "int");
        auto packetsOut1 = registry.callProxy("/blocks/collector_sink", "int");

        auto s2p = registry.callProxy("/blocks/stream_to_packet");
        s2p.callVoid("setMTU", 32); //small fragments
        auto p2s0 = registry.callProxy("/blocks/packet_to_stream");
        auto p2s1 = registry.callProxy("/blocks/packet_to_stream");

        //write the enables register at addr = 1
        SimulationHarness.callVoid("writeControl", 0, 1, enables);

        //create a test plan
        Poco::JSON::Object::Ptr testPlan(new Poco::JSON::Object());
        testPlan->set("enableBuffers", true);
        auto expected = feeder.callProxy("feedTestPlan", testPlan);

        //run the topology
        {
            Pothos::Topology topology;
            topology.connect(feeder, 0, s2p, 0);
            topology.connect(s2p, 0, packetsIn, 0);
            topology.connect(s2p, 0, sink1, 0);

            topology.connect(source1, 0, p2s0, 0);
            topology.connect(source1, 0, packetsOut0, 0);
            topology.connect(p2s0, 0, collector0, 0);

            topology.connect(source2, 0, p2s1, 0);
            topology.connect(source2, 0, packetsOut1, 0);
            topology.connect(p2s1, 0, collector1, 0);

            topology.commit();
            POTHOS_TEST_TRUE(topology.waitInactive());
        }

        if ((enables & 0x1) != 0) collector0.callVoid("verifyTestPlan", expected);
        if ((enables & 0x2) != 0) collector1.callVoid("verifyTestPlan", expected);

        //check that we have the expected packets
        if ((enables & 0x1) != 0)
        {
            const auto pktsIn = packetsIn.call<std::vector<Pothos::Object>>("getMessages");
            const auto pktsOut = packetsOut0.call<std::vector<Pothos::Object>>("getMessages");
            POTHOS_TEST_EQUAL(pktsIn.size(), pktsOut.size());
            for (size_t i = 0; i < pktsIn.size(); i++)
            {
                auto pktIn = pktsIn.at(i).convert<Pothos::Packet>();
                auto pktOut = pktsOut.at(i).convert<Pothos::Packet>();
                POTHOS_TEST_TRUE(pktIn.payload.length == pktOut.payload.length);
                POTHOS_TEST_TRUE(pktIn.payload.dtype == pktOut.payload.dtype);
            }
        }
        if ((enables & 0x2) != 0)
        {
            const auto pktsIn = packetsIn.call<std::vector<Pothos::Object>>("getMessages");
            const auto pktsOut = packetsOut1.call<std::vector<Pothos::Object>>("getMessages");
            POTHOS_TEST_EQUAL(pktsIn.size(), pktsOut.size());
            for (size_t i = 0; i < pktsIn.size(); i++)
            {
                auto pktIn = pktsIn.at(i).convert<Pothos::Packet>();
                auto pktOut = pktsOut.at(i).convert<Pothos::Packet>();
                POTHOS_TEST_TRUE(pktIn.payload.length == pktOut.payload.length);
                POTHOS_TEST_TRUE(pktIn.payload.dtype == pktOut.payload.dtype);
            }
        }
    }
}
