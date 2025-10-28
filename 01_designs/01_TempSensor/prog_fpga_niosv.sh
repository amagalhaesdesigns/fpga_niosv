#!/bin/bash

# Configure FPGA fabric with .sof file.
echo "******** Program FPGA ********"
quartus_pgm -c 1 -m jtag -o "p;./output_files/fpga_niosv.sof@1"


# Load the elf file in NIOS V memory
echo "******** Program NIOS ********"
niosv-download -c 1 ./software/app/build/debug/main.elf


# Run the loaded file
echo "******** Run NIOS-V ********"
niosv-download -c 1 -g

