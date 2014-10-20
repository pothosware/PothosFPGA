// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#pragma once
#include <Pothos/Proxy/Environment.hpp>
#include <string>

Pothos::ProxyEnvironment::Sptr getSimulationEnv(const std::string &testName);
