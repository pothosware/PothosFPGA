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
    for (size_t i = 0; i < 50; i++)
    {
        for (size_t j = 0; j < 5; j++)
        {
            void *buff0;
            size_t length0;
            ret = xudma_mm2s_acquire(&user, &buff0, &length0);
            if (ret < 0)
            {
                printf("xudma_mm2s_acquire() failed %d\n", ret);
                return -1;
            }
            int *p = (int *)buff0;
            for (size_t k = 0; k < 128; k++)
            {
                p[k] = (i << 16) | (j << 8) | k;
            }
            xudma_mm2s_release(&user, ret, 1024);
        }

        for (size_t j = 0; j < 5; j++)
        {
            void *buff1;
            size_t length1;
            ret = xudma_s2mm_acquire(&user, &buff1, &length1);
            if (ret < 0)
            {
                printf("xudma_s2mm_acquire() failed %d\n", ret);
                return -1;
            }
            if (length1 != 1024)
            {
                printf("error buff1 length = %d\n", length1);
            }
            const int *p = (const int *)buff1;
            for (size_t k = 0; k < 128; k++)
            {
                if (p[k] != ((i << 16) | (j << 8) | k))
                {
                    printf("error got %d @ i = %d, j = %d, k = %d \n", p[k], i, j, k);
                }
            }
            xudma_s2mm_release(&user, ret);
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
