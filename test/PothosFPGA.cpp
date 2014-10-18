#include <iostream>
#include <cstdlib>

static int sourceIndex = 1;

/***********************************************************************
 * output interface
 **********************************************************************/
extern "C" int PothosFPGA_setupOutput(const int portIndex)
{
    //std::cout << "PothosFPGA_setupOutput " << portIndex << std::endl;
    return portIndex;
}

extern "C" bool PothosFPGA_outputHasData(const int handle)
{
    //std::cout << "PothosFPGA_outputHasData " << handle << std::endl;
    if (sourceIndex > 5) exit(0);
    return true;
}

extern "C" bool PothosFPGA_outputPopData(const int handle)
{
    //std::cout << "PothosFPGA_outputPopData " << handle << std::endl;
    sourceIndex++;
    return true;
}

extern "C" int PothosFPGA_outputFrontData(const int handle)
{
    //std::cout << "PothosFPGA_outputFrontData " << handle << std::endl;
    return sourceIndex;
}

/***********************************************************************
 * input interface
 **********************************************************************/
extern "C" int PothosFPGA_setupInput(const unsigned portIndex)
{
    //std::cout << "PothosFPGA_setupInput " << portIndex << std::endl;
    return portIndex;
}

extern "C" bool PothosFPGA_inputHasSpace(const int handle)
{
    //std::cout << "PothosFPGA_inputHasSpace " << handle << std::endl;
    return true;
}

extern "C" bool PothosFPGA_inputPushData(const int handle, const int data)
{
    //std::cout << "PothosFPGA_inputPushData " << handle << std::endl;
    std::cout << "PothosFPGA_inputPushData got " << data << std::endl;
    return true;
}
