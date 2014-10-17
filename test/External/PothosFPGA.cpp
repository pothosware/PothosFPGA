#include <iostream>

extern "C" int PothosFPGA_setupOutput(const unsigned portIndex)
{
    std::cout << "PothosFPGA_setupOutput " << portIndex << std::endl;
    return 0;
}
