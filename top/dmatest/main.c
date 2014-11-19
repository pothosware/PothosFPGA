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
    xilinx_user_dma_t user;
    user.hardware_register_base = 0x40400000; //GP0 master mapped here
    user.hardware_shared_base = 0x10000000; //boot args gave up upper 256M
    user.hardware_shared_size = 0x10000000; //take entire upper 256M
    user.mm2s_buffer_size = 1024;
    user.s2mm_buffer_size = 1024;
    user.mm2s_num_buffers = 4;
    user.s2mm_num_buffers = 4;

    int ret = 0;

    printf("---- xilinx_user_dma_create() ----\n");
    ret = xilinx_user_dma_create(&user);
    if (ret != XILINX_USER_DMA_OK)
    {
        printf("xilinx_user_dma_create() failed %d\n", ret);
        return -1;
    }

    printf("---- xilinx_user_dma_init() ----\n");
    ret = xilinx_user_dma_init(&user, XILINX_USER_DMA_MM2S) &&
          xilinx_user_dma_init(&user, XILINX_USER_DMA_S2MM);
    if (ret != XILINX_USER_DMA_OK)
    {
        printf("xilinx_user_dma_init() failed %d\n", ret);
        return -1;
    }

    printf("---- xilinx_user_dma_halt() ----\n");
    ret = xilinx_user_dma_halt(&user, XILINX_USER_DMA_MM2S) &&
          xilinx_user_dma_halt(&user, XILINX_USER_DMA_S2MM);
    if (ret != XILINX_USER_DMA_OK)
    {
        printf("xilinx_user_dma_halt() failed %d\n", ret);
        return -1;
    }

    printf("---- xilinx_user_dma_destroy() ----\n");
    ret = xilinx_user_dma_destroy(&user);
    if (ret != XILINX_USER_DMA_OK)
    {
        printf("xilinx_user_dma_destroy() failed %d\n", ret);
        return -1;
    }

    printf("========== End DMA Test =============\n");
    return 0;
}
