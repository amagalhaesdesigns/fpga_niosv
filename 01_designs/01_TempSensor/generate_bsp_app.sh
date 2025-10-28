#!/bin/bash

#To generate the BSP
echo "******** Generate BSP ********"
niosv-bsp --create --type=freertos --sopcinfo=niosv.sopcinfo --bsp-dir=./software/bsp ./software/bsp/settings.bsp
 

# To invoke BSP Editor to edit the BSP of actual project
#niosv-bsp-editor --settings ./software/bsp/settings.bsp


# To generate the cmake file for the app
echo "******** Generate the cmake file for the app ********"
niosv-app --bsp-dir=./software/bsp --app-dir=software/app --srcs=software/app/main.c --elf-name=main.elf

 
# Run cmake to build the make file
echo "******** cmake to build the make file ********"
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -B software/app/build/Debug -S software/app

 
# Run make to build the .elf file (File to run on NIOS V)
echo "******** Run make to build the .elf file ********"
make -C software/app/build/Debug

