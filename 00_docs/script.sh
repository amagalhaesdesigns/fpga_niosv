#!/bin/bash

#To generate the BSP
niosv-bsp --create --type=freertos --sopcinfo=niosv.sopcinfo --bsp-dir=./software/bsp ./software/bsp/settings.bsp
 

# To invoke BSP Editor to edit the BSP of actual project
niosv-bsp-editor --settings ./software/bsp/settings.bsp

 

# To generate the cmake file for the app
niosv-app --bsp-dir=./software/bsp --app-dir=software/app --srcs=software/app/main.c --elf-name=main.elf

 

# Run cmake to build the make file
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -B software/app/build -S software/app

 

# Run make to build the .elf file (File to run on NIOS V
make -C software/app/build

 

# Configure FPGA fabric with .sof file.
quartus_pgm -c 1 -m JTAG -o p;./output_files/fpga_niosv.sof@1


# Load the elf file in NIOS V memory
# If want to run also the program after downloading it, add -g option to bellow command line.
niosv-download -c 1 ./software/app/build/main.elf

 

# Open JTAG Uart to receive the sent message
# Open JTAG UART in another terminal before running the programa.
juart-terminal -c 1

 

# Run the loaded file
niosv-download -c 1 -g

 

# Extra step Generate HEX file to program the OCR
# Run this command in /sw/app_custom/debug directory (Where .elf file is located)
elf2hex --base=0 --end=0x1ffff --debug --input=main.elf --width=32 --outpu=main.hex

 

# End of file