/***********************************************************************
 * AXI DMA v7.1 Example Driver for Scatter/Gather mode
 *
 * Implement the DMA test in userspace:
 * Open /dev/mem and map shared memory and control registers.
 **********************************************************************/
#include <stdio.h>
#include "xilinx_user_dma.h"

/***********************************************************************
 * main entry point
 **********************************************************************/
int main(void)
{
    printf("========== Begin DMA Test =============\n");

    //! Physical memory constants based on boot config (device tree and bootargs)
    xudma_t user;
    user.hardware_register_base = 0x40400000; //GP0 master mapped here
    user.hardware_shared_base = 0x10000000; //boot args gave up upper 256M
    user.hardware_shared_size = 0x10000000; //take entire upper 256M
    user.mm2s_buffer_size = 1024;
    user.s2mm_buffer_size = 1024;
    user.mm2s_num_buffers = 4;
    user.s2mm_num_buffers = 4;

    int ret = 0;

    /*******************************************************************
     * setup
     ******************************************************************/
    printf("---- xudma_create() ----\n");
    ret = xudma_create(&user);
    if (ret != XUDMA_OK)
    {
        printf("xudma_create() failed %d\n", ret);
        return -1;
    }

    printf("---- xudma_reset() ----\n");
    ret = xudma_reset(&user);
    if (ret != XUDMA_OK)
    {
        printf("xudma_reset() failed %d\n", ret);
        return -1;
    }

    printf("---- xudma_s2mm_init() ----\n");
    ret = xudma_s2mm_init(&user);
    if (ret != XUDMA_OK)
    {
        printf("xudma_s2mm_init() failed %d\n", ret);
        return -1;
    }

    printf("---- xudma_mm2s_init() ----\n");
    ret = xudma_mm2s_init(&user);
    if (ret != XUDMA_OK)
    {
        printf("xudma_mm2s_init() failed %d\n", ret);
        return -1;
    }

    /*******************************************************************
     * stream test
     ******************************************************************/
    printf("---- stream test ----\n");
    for (size_t j = 0; j < 2; j++)
    {
        for (size_t i = 0; i < 3; i++)
        {
            xudma_buffer_t buff0;
            ret = xudma_mm2s_acquire(&user, &buff0, 0);
            if (ret != XUDMA_OK)
            {
                printf("xudma_mm2s_acquire() failed %d\n", ret);
                return -1;
            }
            xudma_mm2s_release(&user, buff0.handle, 128);
        }

            sleep(1);

        for (size_t i = 0; i < 3; i++)
        {
            xudma_buffer_t buff1;
            ret = xudma_s2mm_acquire(&user, &buff1, 0);
            if (ret != XUDMA_OK)
            {
                printf("xudma_s2mm_acquire() failed %d\n", ret);
                return -1;
            }
            printf("buff1 length = %d\n", buff1.length);
            xudma_s2mm_release(&user, buff1.handle);
        }
    }

    /*******************************************************************
     * cleanup
     ******************************************************************/
    printf("---- xudma_s2mm_halt() ----\n");
    ret = xudma_s2mm_halt(&user);
    if (ret != XUDMA_OK)
    {
        printf("xudma_s2mm_halt() failed %d\n", ret);
        return -1;
    }

    printf("---- xudma_mm2s_halt() ----\n");
    ret = xudma_mm2s_halt(&user);
    if (ret != XUDMA_OK)
    {
        printf("xudma_mm2s_halt() failed %d\n", ret);
        return -1;
    }

    printf("---- xudma_destroy() ----\n");
    ret = xudma_destroy(&user);
    if (ret != XUDMA_OK)
    {
        printf("xudma_destroy() failed %d\n", ret);
        return -1;
    }

    printf("========== End DMA Test =============\n");
    return 0;
}
