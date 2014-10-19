// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Testing.hpp>
#include <Pothos/System.hpp>
#include <Pothos/Remote.hpp>
#include <Pothos/Proxy.hpp>
#include <Pothos/Framework.hpp>
#include <Poco/Pipe.h>
#include <Poco/PipeStream.h>
#include <Poco/Process.h>
#include <Poco/Path.h>
#include <Poco/JSON/Object.h>
#include <Poco/StringTokenizer.h>
#include <thread>
#include <iostream>

POTHOS_TEST_BLOCK("/fpga/tests", test_simple_loopback)
{
    Poco::Path testPath(Pothos::System::getPothosDevLibraryPath());
    testPath.append("Pothos");
    testPath.append("fpga");
    testPath.append("test");

    Poco::Process::Args args;
    args.push_back("-r");
    args.push_back("simpleloopbacktb");
    Poco::Pipe outPipe, errPipe;
    Poco::Process::Env envVars;
    envVars["POTHOS_FPGA_SERVER_ADDR"] = "tcp://0.0.0.0:12345";
    Poco::ProcessHandle ph(Poco::Process::launch(
        "ghdl", args, testPath.toString(), nullptr, /*&outPipe, &errPipe*/nullptr, nullptr, envVars));

    //read port and close pipe
    std::string port = "12345";
    /*
    Poco::PipeInputStream is(outPipe);
    while (is.good() and not is.eof())
    {
        std::string line; std::getline(is, line);
        if (line.empty()) continue;
        const Poco::StringTokenizer tok(line, " ");
        if (tok.count() >= 2 and tok[0] == "Port:")
        {
            port = tok[1];
            break;
        }
    }

    //close pipes to not overfill and backup
    outPipe.close();
    errPipe.close();
    */
    std::this_thread::sleep_for(std::chrono::milliseconds(1000));

    Pothos::RemoteClient client("tcp://localhost:"+port);
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
