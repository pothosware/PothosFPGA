// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/System.hpp>
#include <Pothos/Remote.hpp>
#include <Pothos/Proxy.hpp>
#include <Poco/Process.h>
#include <Poco/Path.h>
#include <Poco/NamedMutex.h>
#include <memory>

Pothos::ProxyEnvironment::Sptr getSimulationEnv(const std::string &testName)
{
    static const std::string serverPort = std::to_string(1024+Poco::Process::id());
    static const std::string mutexName = "ghdl_"+testName+serverPort;

    //test install directory
    Poco::Path testPath(Pothos::System::getPothosDevLibraryPath());
    testPath.append("Pothos");
    testPath.append("fpga");
    testPath.append("test");

    //setup args and env vars
    Poco::Process::Args args;
    args.push_back("-r");
    args.push_back(testName);
    Poco::Process::Env envVars;
    envVars["POTHOS_FPGA_SERVER_PORT"] = serverPort;
    envVars["POTHOS_FPGA_MUTEX_NAME"] = mutexName;

    //launch with named mutex barrier
    Poco::NamedMutex mutex(mutexName);
    mutex.lock();
    std::shared_ptr<Poco::ProcessHandle> phc;
    phc.reset(new Poco::ProcessHandle(Poco::Process::launch(
        "ghdl", args, testPath.toString(), nullptr, nullptr, nullptr, envVars)));
    mutex.lock();
    mutex.unlock();

    //create client environment
    Pothos::RemoteClient client("tcp://localhost:"+serverPort);
    client.holdRef(Pothos::Object(phc));
    return client.makeEnvironment("managed");
}
