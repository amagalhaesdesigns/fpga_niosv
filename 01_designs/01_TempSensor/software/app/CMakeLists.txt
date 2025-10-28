cmake_minimum_required(VERSION 3.14)

add_subdirectory(../bsp bsp)

include(../bsp/toolchain.cmake)

project(main)

add_executable(main.elf)

target_sources(main.elf
    PRIVATE
        main.c
        adt7301.c
)

target_include_directories(main.elf
    PRIVATE
    PUBLIC
)

target_link_libraries(main.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump main.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS main.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" main.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file main.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS main.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" main.elf
    COMMENT "Reporting memory available for stack + heap in main.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")
