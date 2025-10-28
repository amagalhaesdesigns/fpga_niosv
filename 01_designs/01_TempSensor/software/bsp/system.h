/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'niosv' in SOPC Builder design 'niosv'
 * SOPC Builder design path: ../../niosv.sopcinfo
 *
 * Generated: Tue Oct 28 17:01:32 BRT 2025
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "intel_niosv_g"
#define ALT_CPU_CPU_FREQ 50000000u
#define ALT_CPU_DATA_ADDR_WIDTH 0x20
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 4096
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_HAS_CSR_SUPPORT 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 4096
#define ALT_CPU_INST_ADDR_WIDTH 0x20
#define ALT_CPU_MTIME_OFFSET 0x40010000
#define ALT_CPU_NAME "niosv"
#define ALT_CPU_NIOSV_CORE_VARIANT 3
#define ALT_CPU_NUM_GPR 32
#define ALT_CPU_RESET_ADDR 0x00000000
#define ALT_CPU_TICKS_PER_SEC NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND
#define ALT_CPU_TIMER_DEVICE_TYPE 2


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define BANTAMLAKE_CPU_FREQ 50000000u
#define BANTAMLAKE_DATA_ADDR_WIDTH 0x20
#define BANTAMLAKE_DCACHE_LINE_SIZE 32
#define BANTAMLAKE_DCACHE_LINE_SIZE_LOG2 5
#define BANTAMLAKE_DCACHE_SIZE 4096
#define BANTAMLAKE_HAS_CSR_SUPPORT 1
#define BANTAMLAKE_HAS_DEBUG_STUB
#define BANTAMLAKE_ICACHE_LINE_SIZE 32
#define BANTAMLAKE_ICACHE_LINE_SIZE_LOG2 5
#define BANTAMLAKE_ICACHE_SIZE 4096
#define BANTAMLAKE_INST_ADDR_WIDTH 0x20
#define BANTAMLAKE_MTIME_OFFSET 0x40010000
#define BANTAMLAKE_NIOSV_CORE_VARIANT 3
#define BANTAMLAKE_NUM_GPR 32
#define BANTAMLAKE_RESET_ADDR 0x00000000
#define BANTAMLAKE_TICKS_PER_SEC NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND
#define BANTAMLAKE_TIMER_DEVICE_TYPE 2


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_SPI
#define __ALTERA_AVALON_TIMER
#define __ALTERA_MEM_IF_DDR3_EMIF
#define __INTEL_NIOSV_G


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone V"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x40010080
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x40010080
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x40010080
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "niosv"
#define ALT_SYS_CLK_TICKS_PER_SEC ALT_CPU_TICKS_PER_SEC
#define ALT_TIMESTAMP_CLK_TIMER_DEVICE_TYPE ALT_CPU_TIMER_DEVICE_TYPE


/*
 * adt7301 configuration
 *
 */

#define ADT7301_BASE 0x40010040
#define ADT7301_CLOCKMULT 1
#define ADT7301_CLOCKPHASE 0
#define ADT7301_CLOCKPOLARITY 0
#define ADT7301_CLOCKUNITS "Hz"
#define ADT7301_DATABITS 8
#define ADT7301_DATAWIDTH 16
#define ADT7301_DELAYMULT "1.0E-9"
#define ADT7301_DELAYUNITS "ns"
#define ADT7301_EXTRADELAY 0
#define ADT7301_INSERT_SYNC 0
#define ADT7301_IRQ 2
#define ADT7301_IRQ_INTERRUPT_CONTROLLER_ID 0
#define ADT7301_ISMASTER 1
#define ADT7301_LSBFIRST 0
#define ADT7301_NAME "/dev/adt7301"
#define ADT7301_NUMSLAVES 1
#define ADT7301_PREFIX "spi_"
#define ADT7301_SPAN 32
#define ADT7301_SYNC_REG_DEPTH 2
#define ADT7301_TARGETCLOCK 200000u
#define ADT7301_TARGETSSDELAY "0.0"
#define ADT7301_TYPE "altera_avalon_spi"
#define ALT_MODULE_CLASS_adt7301 altera_avalon_spi


/*
 * freertos configuration
 *
 */

#define HEAP_METHOD 4
#define OS_CHECK_STACK_OVERFLOW 1
#define OS_COUNTING_SEM_EN 1
#define OS_IDLE_SHOULD_YEILD 0
#define OS_MALLOC_FAILED_HOOK_EN 0
#define OS_MAX_PRIORITIES 7
#define OS_MAX_TASK_NAME_LEN 16
#define OS_MEMORY_DYNAMIC_ALLOCATION_EN 1
#define OS_MIN_STACK_SIZE 300
#define OS_MUTEX_EN 1
#define OS_PORT_HAS_MTIME 1
#define OS_Q_REG_SIZE 8
#define OS_RECURSIVE_MUTEX_EN 1
#define OS_SEMAPHORE_GET_MUTEX_HOLDER_EN 1
#define OS_TASK_ABORT_DELAY_EN 1
#define OS_TASK_CLEAN_UP_RESOURCES_EN 1
#define OS_TASK_DELAY_EN 1
#define OS_TASK_DELAY_UNTIL_EN 1
#define OS_TASK_DELETE_EN 1
#define OS_TASK_GET_HANDLE_EN 1
#define OS_TASK_GET_STATE_EN 1
#define OS_TASK_PRIORITY_GET_EN 1
#define OS_TASK_PRIORITY_SET_EN 1
#define OS_TASK_SUSPEND_EN 1
#define OS_THREAD_SAFE_C_LIBRARY 1
#define OS_TICKS_PER_SEC ALT_SYS_CLK_TICKS_PER_SEC
#define OS_TIMER_PEND_FUNCTION_CALL_EN 1
#define OS_TIMER_QUEUE_LEN 8
#define OS_TIMER_TASK_DEPTH 160
#define OS_TLS_BYTES_PER_TASK 256
#define OS_TOTAL_HEAP_SIZE 80000
#define OS_USE_16_BIT_TICKS 0
#define OS_USE_IDLE_HOOK 0
#define OS_USE_PREEMPTION 1
#define OS_USE_QUEUE_SETS 1
#define OS_USE_TICK_HOOK 1
#define OS_USE_TIMERS 1
#define OS_USE_TRACE_FACILITY 1


/*
 * hal2 configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK NIOSV
#define ALT_TIMESTAMP_CLK NIOSV
#define INTEL_FPGA_DFL_START_ADDRESS 0xffffffffffffffff
#define INTEL_FPGA_USE_DFL_WALKER 0


/*
 * intel_niosv_g_freertos_driver configuration
 *
 */

#define NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND 1000


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x40010080
#define JTAG_UART_IRQ 1
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * mem_if_ddr3_emif_fpga configuration
 *
 */

#define ALT_MODULE_CLASS_mem_if_ddr3_emif_fpga altera_mem_if_ddr3_emif
#define MEM_IF_DDR3_EMIF_FPGA_BASE 0x0
#define MEM_IF_DDR3_EMIF_FPGA_IRQ -1
#define MEM_IF_DDR3_EMIF_FPGA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MEM_IF_DDR3_EMIF_FPGA_NAME "/dev/mem_if_ddr3_emif_fpga"
#define MEM_IF_DDR3_EMIF_FPGA_SPAN 1073741824
#define MEM_IF_DDR3_EMIF_FPGA_TYPE "altera_mem_if_ddr3_emif"


/*
 * sys_clk configuration
 *
 */

#define ALT_MODULE_CLASS_sys_clk altera_avalon_timer
#define SYS_CLK_ALWAYS_RUN 0
#define SYS_CLK_BASE 0x40010060
#define SYS_CLK_COUNTER_SIZE 32
#define SYS_CLK_FIXED_PERIOD 0
#define SYS_CLK_FREQ 50000000
#define SYS_CLK_IRQ 0
#define SYS_CLK_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SYS_CLK_LOAD_VALUE 49999
#define SYS_CLK_MULT 0.001
#define SYS_CLK_NAME "/dev/sys_clk"
#define SYS_CLK_PERIOD 1
#define SYS_CLK_PERIOD_UNITS "ms"
#define SYS_CLK_RESET_OUTPUT 0
#define SYS_CLK_SNAPSHOT 1
#define SYS_CLK_SPAN 32
#define SYS_CLK_TICKS_PER_SEC 1000
#define SYS_CLK_TIMEOUT_PULSE_OUTPUT 0
#define SYS_CLK_TIMER_DEVICE_TYPE 1
#define SYS_CLK_TYPE "altera_avalon_timer"

#endif /* __SYSTEM_H_ */
