// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <Pothos/Config.hpp>
#include <iostream>
#include <cstdlib>

#define EXPORT_TO_VHDL extern "C" POTHOS_HELPER_DLL_EXPORT

/***********************************************************************
 * output interface
 **********************************************************************/
EXPORT_TO_VHDL int PothosFPGA_setupOutput(const int portIndex)
{
    //std::cout << "PothosFPGA_setupOutput " << portIndex << std::endl;
    return portIndex;
}

static int sourceIndex = 1;

EXPORT_TO_VHDL bool PothosFPGA_outputHasData(const int handle)
{
    //std::cout << "PothosFPGA_outputHasData " << handle << std::endl;
    if (sourceIndex > 5) exit(0);
    return true;
}

EXPORT_TO_VHDL bool PothosFPGA_outputPopData(const int handle)
{
    //std::cout << "PothosFPGA_outputPopData " << handle << std::endl;
    sourceIndex++;
    return true;
}

EXPORT_TO_VHDL int PothosFPGA_outputFrontData(const int handle)
{
    //std::cout << "PothosFPGA_outputFrontData " << handle << std::endl;
    return sourceIndex;
}

/***********************************************************************
 * input interface
 **********************************************************************/
EXPORT_TO_VHDL int PothosFPGA_setupInput(const unsigned portIndex)
{
    //std::cout << "PothosFPGA_setupInput " << portIndex << std::endl;
    return portIndex;
}

EXPORT_TO_VHDL bool PothosFPGA_inputHasSpace(const int handle)
{
    //std::cout << "PothosFPGA_inputHasSpace " << handle << std::endl;
    return true;
}

EXPORT_TO_VHDL bool PothosFPGA_inputPushData(const int handle, const int data)
{
    //std::cout << "PothosFPGA_inputPushData " << handle << std::endl;
    std::cout << "PothosFPGA_inputPushData got " << data << std::endl;
    return true;
}
