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

int main(int argc, const char* argv[])
{
    printf("Begin pothos axi stream userspace test\n");
    if (argc != 2)
    {
        printf("Expects device node as arg1\n");
        return EXIT_FAILURE;
    }

    //open the device
    int fd = open(argv[1], O_RDWR | O_SYNC);
    if (fd <= 0)
    {
        perror("open");
        return EXIT_FAILURE;
    }

    //try to mmap
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

    //try to dma map
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

    //close
    close(fd);

    printf("Done!\n");
    return EXIT_SUCCESS;
}
