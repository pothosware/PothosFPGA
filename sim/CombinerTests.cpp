// Copyright (c) 2014-2014 Josh Blum
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
        POTHOS_TEST_TRUE(topology.waitInactive());
    }

    collector.callVoid("verifyTestPlan", expected);
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
            POTHOS_TEST_TRUE(topology.waitInactive());
        }

        collector.callVoid("verifyTestPlan", expected);
    }
}
