// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <stdio.h>
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

    ////////////////// alloc /////////////////
    ret = pzdud_alloc(dma, PZDUD_S2MM, 4, 4096);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_alloc %d\n", ret);
        return EXIT_FAILURE;
    }
    ret = pzdud_alloc(dma, PZDUD_MM2S, 4, 4096);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_alloc %d\n", ret);
        return EXIT_FAILURE;
    }

    ////////////// init engine ///////////////
    ret = pzdud_init(dma, PZDUD_S2MM);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_init %d\n", ret);
        return EXIT_FAILURE;
    }
    ret = pzdud_init(dma, PZDUD_MM2S);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_init %d\n", ret);
        return EXIT_FAILURE;
    }

    /////////////// test loopback ////////////////
    void *buff;
    size_t len;
    int handle = pzdud_acquire(dma, PZDUD_MM2S, &buff, &len);
    if (handle < 0)
    {
        printf("Fail pzdud_acquire(mm2s) %d\n", handle);
        return EXIT_FAILURE;
    }
    printf("available %d bytes\n", len);
    pzdud_release(dma, PZDUD_MM2S, handle, 64);

    sleep(1);
    handle = pzdud_acquire(dma, PZDUD_S2MM, &buff, &len);
    if (handle < 0)
    {
        printf("Fail pzdud_acquire(s2mm) %d\n", handle);
        return EXIT_FAILURE;
    }
    printf("recv %d bytes\n", len);
    pzdud_release(dma, PZDUD_S2MM, handle, 0);

    /////////////// halt engine /////////////
    ret = pzdud_halt(dma, PZDUD_S2MM);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_halt %d\n", ret);
        return EXIT_FAILURE;
    }
    ret = pzdud_halt(dma, PZDUD_MM2S);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_halt %d\n", ret);
        return EXIT_FAILURE;
    }

    ////////////////// free /////////////////
    ret = pzdud_free(dma, PZDUD_S2MM);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_free %d\n", ret);
        return EXIT_FAILURE;
    }
    ret = pzdud_free(dma, PZDUD_MM2S);
    if (ret != PZDUD_OK)
    {
        printf("Fail pzdud_free %d\n", ret);
        return EXIT_FAILURE;
    }

    ////////////////// cleanup /////////////////
    pzdud_destroy(dma);
    printf("Done!\n");

    return EXIT_SUCCESS;
}