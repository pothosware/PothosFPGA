// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Testing.hpp>
#include <Pothos/System.hpp>
#include <Pothos/Remote.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/Process.h>
#include <Poco/Path.h>
#include <Poco/JSON/Object.h>
#include <Poco/NamedMutex.h>
#include <iostream>

POTHOS_TEST_BLOCK("/fpga/tests", test_simple_loopback)
{
    static const std::string serverPort = "12345";
    static const std::string mutexName = "abcdef";

    //test install directory
    Poco::Path testPath(Pothos::System::getPothosDevLibraryPath());
    testPath.append("Pothos");
    testPath.append("fpga");
    testPath.append("test");

    //setup args and env vars
    Poco::Process::Args args;
    args.push_back("-r");
    args.push_back("simpleloopbacktb");
    Poco::Process::Env envVars;
    envVars["POTHOS_FPGA_SERVER_PORT"] = serverPort;
    envVars["POTHOS_FPGA_MUTEX_NAME"] = mutexName;

    //launch with named mutex barrier
    Poco::NamedMutex mutex(mutexName);
    mutex.lock();
    Poco::ProcessHandle ph(Poco::Process::launch(
        "ghdl", args, testPath.toString(), nullptr, nullptr, nullptr, envVars));
    mutex.lock();
    mutex.unlock();

    //create client environment
    Pothos::RemoteClient client("tcp://localhost:"+serverPort);
    auto env = client.makeEnvironment("managed");
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
    std::cout << "run the topology" << std::endl;
    {
        Pothos::Topology topology;
        topology.connect(feeder, 0, sink0, 0);
        topology.connect(source0, 0, collector, 0);
        topology.commit();
        POTHOS_TEST_TRUE(topology.waitInactive());
    }

    std::cout << "verifyTestPlan" << std::endl;
    collector.callVoid("verifyTestPlan", expected);
}
