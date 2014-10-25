// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include "SimulationClient.hpp"
#include <Pothos/System.hpp>
#include <Pothos/Remote.hpp>
#include <Pothos/Proxy.hpp>
#include <Poco/Process.h>
#include <Poco/Path.h>
#include <Poco/File.h>
#include <Poco/NamedMutex.h>
#include <Poco/String.h>
#include <Poco/Environment.h>
#include <iostream>
#include <memory>

Pothos::ProxyEnvironment::Sptr getSimulationEnv(const std::string &testName)
{
    const std::string serverPort = std::to_string(1024+Poco::Process::id());
    const std::string mutexName = "pothos_spawn_ghdl_simulation_barrier";

    //path to vcd output
    Poco::Path vcdFile(Poco::Path::temp());
    vcdFile.append(testName+".vcd");
    std::cout << "Output: " << vcdFile.toString() << std::endl;

    //test install directory
    Poco::Path testPath(Pothos::System::getPothosDevLibraryPath());
    testPath.append("Pothos");
    testPath.append("fpga");
    testPath.append("test");
    testPath.append(Poco::toLower(testName));

    //check that the file exists
    if (not Poco::File(testPath).exists()) throw Pothos::FileExistsException(testPath.toString());

    //setup args and env vars
    Poco::Process::Args args;
    args.push_back("-r");
    args.push_back(Poco::toLower(testPath.getFileName()));
    args.push_back("--vcd="+vcdFile.toString());
    Poco::Process::Env envVars;
    envVars["POTHOS_FPGA_SERVER_PORT"] = serverPort;
    envVars["POTHOS_FPGA_MUTEX_NAME"] = mutexName;

    //ghdl doesnt support -rpath, execute with library path set
    envVars["LD_LIBRARY_PATH"] = Pothos::System::getPothosDevLibraryPath();
    envVars["LD_LIBRARY_PATH"] += ":"+Poco::Environment::get("LD_LIBRARY_PATH", "");

    //launch with named mutex barrier
    Poco::NamedMutex mutex(mutexName);
    mutex.lock();
    std::shared_ptr<Poco::ProcessHandle> phc;
    phc.reset(new Poco::ProcessHandle(Poco::Process::launch(
        "ghdl", args, testPath.parent().toString(), nullptr, nullptr, nullptr, envVars)));
    mutex.lock();
    mutex.unlock();

    //create client environment
    Pothos::RemoteClient client("tcp://localhost:"+serverPort);
    client.holdRef(Pothos::Object(phc));
    return client.makeEnvironment("managed");
}
