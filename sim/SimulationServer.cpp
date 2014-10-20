// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Init.hpp>
#include <Pothos/Remote.hpp>
#include <Poco/Net/ServerSocket.h>
#include <Poco/Net/SocketStream.h>
#include <Poco/Environment.h>
#include <Poco/NamedMutex.h>
#include <Poco/Process.h>
#include <iostream>
#include <cstdlib>

void runProxyServer(void)
{
    //set stdio to be unbuffered to prevent IO backup when this is a subprocess
    std::cout.setf(std::ios::unitbuf);
    std::cerr.setf(std::ios::unitbuf);
    std::clog.setf(std::ios::unitbuf);

    Pothos::init();

    //start the server
    const auto port = Poco::Environment::get("POTHOS_FPGA_SERVER_PORT");
    Poco::Net::ServerSocket serverSocket(Poco::Net::SocketAddress("localhost", port));
    std::cout << "Host: " << serverSocket.address().host().toString() << std::endl;
    std::cout << "Port: " << serverSocket.address().port() << std::endl;
    Poco::NamedMutex mutex(Poco::Environment::get("POTHOS_FPGA_MUTEX_NAME"));
    mutex.unlock(); //unlock barrier

    //handle client
    auto client = serverSocket.acceptConnection();
    Poco::Net::SocketStream socketStream(client);
    Pothos::RemoteHandler handler(client.peerAddress().host().toString());
    handler.runHandler(socketStream, socketStream);
    std::cout << "killing process" << std::endl;
    Poco::Process::kill(Poco::Process::id());
}
