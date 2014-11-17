#!/bin/bash

#puts bootgen in path
source /opt/Xilinx/SDK/2014.3.1/settings64.sh

#make device tree
dtc  -I dts -O dtb -o ./devicetree.dtb ./system.dts

#make boot.bin from files specified in bif
bootgen -image fsbl.bif -w -o i BOOT.bin
