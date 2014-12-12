// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <stdio.h>
/*
#include <stdlib.h>
#include <sys/types.h> //open
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h> //mmap
#include <unistd.h> //close
#include <stdint.h>
#include "pothos_zynq_dma_ioctl.h"
#include <sys/ioctl.h>
*/
#include "pothos_zynq_dma_user_driver.h"

int main(int argc, const char* argv[])
{
    int ret = 0;
    printf("Begin pothos axi stream userspace test\n");

    ////////////////// init /////////////////
    pzdud_t *dma = pzdud_create(0);
    if (dma == NULL)
    {
        printf("Fail pzdud_create\n");
        return EXIT_FAILURE;
    }

    ret = pzdud_reset(dma);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_reset %d\n", ret);
        return EXIT_FAILURE;
    }

    ////////////////// cleanup /////////////////
    pzdud_destroy(dma);
    printf("Done!\n");

    return EXIT_SUCCESS;
}
