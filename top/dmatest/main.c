/***********************************************************************
 * AXI DMA v7.1 Example Driver for Scatter/Gather mode
 *
 * Implement the DMA test in userspace:
 * Open /dev/mem and map shared memory and control registers.
 **********************************************************************/
#include <stdio.h>
/*
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
*/
#include "xilinx_user_dma.h"

/*
#define REGS_MEM_BASE 0x40400000 //GP0 master mapped here
#define REGS_MEM_SIZE 4096       //1 page worth covers all DMA registers
#define PHYS_MEM_BASE 0x10000000 //boot args gave up upper 256M
#define PHYS_MEM_SIZE 0x10000000 //take entire upper 256M
*/

/***********************************************************************
 * Helper functions to deal with DMA control
 **********************************************************************/
/*
static void xilinx_poke32(char *addr, uint32_t val)
{
    volatile uint32_t *p = (volatile uint32_t *)addr;
    *p = val;
}

static uint32_t xilinx_peek32(char *addr)
{
    volatile uint32_t *p = (volatile uint32_t *)addr;
    return *p;
}

static bool xilinx_user_dma_create(const xilinx_user_dma_config_t *config, xilinx_user_dma_t *user)
{
    
}

static bool xilinx_user_dma_destroy(xilinx_user_dma_t *user)
{
    
}

static bool xilinx_dma_init(char *base)
{
    //a simple test to check for an expected bit in the first register
    if ((xilinx_peek32(base+XILINX_DMA_CONTROL_OFFSET) & 0x2) == 0)
    {
        printf("xilinx_dma_init: ctrl register bit1 unset");
        return false;
    }

    //perform a soft reset
    xilinx_poke32(base+XILINX_DMA_CONTROL_OFFSET, xilinx_peek32(base+XILINX_DMA_CONTROL_OFFSET) | XILINX_DMA_CR_RESET_MASK);
    int loop = XILINX_DMA_RESET_LOOP;
    while ((xilinx_peek32(base+XILINX_DMA_CONTROL_OFFSET) & XILINX_DMA_CR_RESET_MASK) != 0)
    {
        if (--loop == 0)
        {
            printf("xilinx_dma_init: reset loop timeout");
            return false;
        }
    }

    return true;
}

//__clear_cache TODO
*/

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

    int ret = 0;

    printf("---- xilinx_user_dma_create() ----\n");
    ret = xilinx_user_dma_create(&user);
    if (ret != XILINX_USER_DMA_OK)
    {
        printf("xilinx_user_dma_create() failed %d\n", ret);
        return -1;
    }

    printf("---- xilinx_user_dma_init_engine() ----\n");
    ret = xilinx_user_dma_init_engine(&user);
    if (ret != XILINX_USER_DMA_OK)
    {
        printf("xilinx_user_dma_init_engine() failed %d\n", ret);
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
