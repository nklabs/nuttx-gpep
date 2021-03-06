/**
 * Copyright (c) 2014-2015 Google Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <nuttx/config.h>
#include <nuttx/greybus/tsb_unipro.h>
#include <nuttx/unipro/unipro.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>

# define getreg32(a)          (*(volatile uint32_t *)(a))
# define putreg32(v,a)        (*(volatile uint32_t *)(a) = (v))

#define GPIO_BASE           0x40003000
#define GPIO_DATA           (GPIO_BASE)
#define GPIO_ODATA          (GPIO_BASE + 0x4)
#define GPIO_ODATASET       (GPIO_BASE + 0x8)
#define GPIO_ODATACLR       (GPIO_BASE + 0xc)
#define GPIO_DIR            (GPIO_BASE + 0x10)
#define GPIO_DIROUT         (GPIO_BASE + 0x14)
#define GPIO_DIRIN          (GPIO_BASE + 0x18)

#define GPIO_IO_PULL_UPDOWN_ENABLE_0 0x40000a20
#define UART_IO_PULL_UPDOWN_ENABLE_0 0x40000a24

int nklabs_main(int argc, char **argv) {

    /* int read = 0; */
    /* unsigned int addr = 0; */
    /* unsigned int val = 0; */
    /* char *op = argv[1]; */

    /* if (!strcmp(op, "read") || !strcmp(op, "r")) { */
    /*   read = 1; */
    /* } else if (!strcmp(op, "write") || !strcmp(op, "w")) { */
    /*   val  = strtoul(argv[3], NULL, 16); */
    /* } else { */
    /*   printf("unrecognized operation\n"); */
    /* } */
    /* addr = strtoul(argv[2], NULL, 16); */

    /* printf("op = %s\naddr = %x\nval=%x\n", read ? "Read" : "Write", addr, val); */
    /* printf("...\n"); */

    /* if(read){ */
    /*   printf("%x\n", *((volatile unsigned int*)addr)); */
    /* } else { */
    /*   *((volatile unsigned int*)addr) = val; */
    /* } */

  
  /* putreg32(1 << 5, GPIO_ODATACLR ); */
  /* putreg32(1 << 5, GPIO_DIROUT ); */


  putreg32(1 << 0, UART_IO_PULL_UPDOWN_ENABLE_0 );
  putreg32(1 << 9, GPIO_IO_PULL_UPDOWN_ENABLE_0 );
  putreg32(1 << 9, GPIO_DIRIN );


  return 0;
}
