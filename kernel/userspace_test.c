// Copyright (c) 2014-2014 Josh Blum
// SPDX-License-Identifier: BSL-1.0

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> //open
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h> //mmap
#include <unistd.h> //close
#include <stdint.h>
#include "pothos_zynq_dma_ioctl.h"
#include <sys/ioctl.h>

int main(int argc, const char* argv[])
{
    int ret = 0;
    printf("Begin pothos axi stream userspace test\n");
    if (argc != 2)
    {
        printf("Expects device node as arg1\n");
        return EXIT_FAILURE;
    }

    //////////// open the device  /////////////////////
    int fd = open(argv[1], O_RDWR | O_SYNC);
    if (fd <= 0)
    {
        perror("open");
        return EXIT_FAILURE;
    }

    //////////// try to mmap /////////////////////
    void *p = mmap(NULL, 1024, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (p == MAP_FAILED)
    {
        perror("mmap");
        return EXIT_FAILURE;
    }

    volatile uint32_t *regs = (volatile uint32_t *)p;
    printf("regs0 0x%x\n", regs[0]);
    printf("regs1 0x%x\n", regs[1]);

    munmap(p, 1024);

    //////////////// try to dma map /////////////////////
    /*
    p = mmap(NULL, 1024, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 4096);
    if (p == MAP_FAILED)
    {
        perror("mmap");
        return EXIT_FAILURE;
    }
    volatile uint32_t *data = (volatile uint32_t *)p;
    data[0] = 42;
    printf("data0 %d\n", data[0]);

    munmap(p, 1024);
    */

    //////////// try to ioctl /////////////////////

    pothos_zynq_dma_buff_t buffs[2];
    buffs[0].bytes = 2048;
    buffs[1].bytes = 2048;

    pothos_zynq_dma_alloc_t alloc_args;
    alloc_args.sentinel = POTHOS_ZYNQ_DMA_SENTINEL;
    alloc_args.num_buffs = 2;
    alloc_args.buffs = buffs;

    ret = ioctl(fd, POTHOS_ZYNQ_DMA_ALLOC, (void *)&alloc_args);
    if (ret != 0)
    {
        perror("ioctl - alloc");
        return EXIT_FAILURE;
    }

    for (size_t i = 0; i < alloc_args.num_buffs; i++)
    {
        buffs[i].uaddr = mmap(NULL, buffs[i].bytes, PROT_READ | PROT_WRITE, MAP_SHARED, fd, buffs[i].paddr);
        printf("buffer alloc %d: p=0x%x, k=0x%x, u=0x%x\n", i, buffs[i].paddr, (size_t)buffs[i].kaddr, (size_t)buffs[i].uaddr);
    }

    ret = ioctl(fd, POTHOS_ZYNQ_DMA_FREE);
    if (ret != 0)
    {
        perror("ioctl - free");
        return EXIT_FAILURE;
    }

    //////////// close /////////////////////
    close(fd);

    printf("Done!\n");
    return EXIT_SUCCESS;
}
