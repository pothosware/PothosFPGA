// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Init.hpp>
#include <Pothos/Remote.hpp>
#include <Pothos/Plugin/Loader.hpp>
#include <Poco/Net/ServerSocket.h>
#include <Poco/Net/SocketStream.h>
#include <Poco/Net/TCPServer.h>
#include <Poco/Environment.h>
#include <Poco/Process.h>
#include <Poco/URI.h>
#include <chrono>
#include <thread>
#include <iostream>

class MyTCPServerConnection : public Poco::Net::TCPServerConnection
{
public:
    MyTCPServerConnection(const Poco::Net::StreamSocket &socket):
        Poco::Net::TCPServerConnection(socket),
        _handler(Pothos::RemoteHandler(socket.peerAddress().host().toString()))
    {
        return;
    }

    void run(void)
    {
        Poco::Net::SocketStream socketStream(this->socket());
        _handler.runHandler(socketStream, socketStream);
    }

private:
    Pothos::RemoteHandler _handler;
};

class MyTCPServerConnectionFactory : public Poco::Net::TCPServerConnectionFactory
{
public:
    MyTCPServerConnectionFactory(void)
    {
        return;
    }

    Poco::Net::TCPServerConnection *createConnection(const Poco::Net::StreamSocket &socket)
    {
        return new MyTCPServerConnection(socket);
    }
};

struct MyTCPConnectionMonitor: public Poco::Runnable
{
    MyTCPConnectionMonitor(Poco::Net::TCPServer &server):
        running(true),
        server(server)
    {
        return;
    }

    virtual void run(void)
    {
        while (running)
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            /*
            if (server.currentConnections() == 0)
            {
                std::cerr << "Proxy server: No active connections - killing server" << std::endl;
                Poco::Process::kill(Poco::Process::id());
                return;
            }
            */
        }
        std::cout << __func__ << std::endl;
    }

    bool running;
    Poco::Net::TCPServer &server;
};

static void runProxyServer(const std::string &uriStr)
{
    //set stdio to be unbuffered to prevent IO backup when this is a subprocess
    std::cout.setf(std::ios::unitbuf);
    std::cerr.setf(std::ios::unitbuf);
    std::clog.setf(std::ios::unitbuf);

    Pothos::init();

    //parse the URI
    const std::string defaultUri = "tcp://0.0.0.0:"+Pothos::RemoteServer::getLocatorPort();
    Poco::URI uri(uriStr.empty()?defaultUri:uriStr);
    const std::string &host = uri.getHost();
    const std::string &port = std::to_string(uri.getPort());
    if (uri.getScheme() != "tcp")
    {
        throw Pothos::Exception("PothosUtil::proxyServer("+uriStr+")", "unsupported URI scheme");
    }

    //create server socket
    Poco::Net::SocketAddress sa(host, port);
    Poco::Net::ServerSocket serverSocket(sa);
    Poco::Net::TCPServerConnectionFactory::Ptr factory(new MyTCPServerConnectionFactory());
    Poco::Net::TCPServer tcpServer(factory, serverSocket);

    //start the server
    serverSocket.listen();
    tcpServer.start();
    std::cout << "Host: " << serverSocket.address().host().toString() << std::endl;
    std::cout << "Port: " << serverSocket.address().port() << std::endl;

    //create a TCP connection monitor thread
    MyTCPConnectionMonitor monitor(tcpServer);
    Poco::Thread monitorThread;
    monitorThread.start(monitor);
    monitorThread.join();
    std::cout << "exit?\n";
}

void runProxyServer(void)
{
    runProxyServer(Poco::Environment::get("POTHOS_FPGA_SERVER_ADDR", ""));
}
