// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <Pothos/Proxy/Environment.hpp>
#include <string>

Pothos::ProxyEnvironment::Sptr getSimulationEnv(const std::string &testName);

#include <Pothos/Testing.hpp>
#include <Pothos/Framework.hpp>

//! helper routine to validate packets between two collectors
inline void checkPacketCollectors(const Pothos::Proxy &packetsIn, const Pothos::Proxy &packetsOut)
{
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
