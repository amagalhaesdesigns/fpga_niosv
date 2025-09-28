/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2022 Intel Corporation, Santa Clara, California, USA.         *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/

#include <stdio.h>
#include "alt_types.h"
#include "sys/alt_log_printf.h"
#include "sys/alt_irq.h"
#include "FreeRTOS.h"
#include "task.h"

/* Counter to check ISR or non-ISR context. If the value is non-zero, the
 * context is inside ISR.
 */ 
alt_u32 ulHalNestedInterruptCounter = 0;

/* handle_trap() and alt_tick() are Intel HAL function. */
extern alt_u32 handle_trap( alt_u32 cause, alt_u32 epc, alt_u32 tval );
extern void alt_tick( void );

#define HAL_HANDLE_TRAP();  alt_u32 ulMCAUSE = 0, ulMEPC = 0, ulMTVAL = 0;           \
	                          __asm volatile( "csrr %0, mcause" : "=r"( ulMCAUSE ) );  \
                            __asm volatile( "csrr %0, mepc" : "=r"( ulMEPC ) );      \
                            __asm volatile( "csrr %0, mtval" : "=r"( ulMTVAL ) );    \
                            ulHalNestedInterruptCounter++;                           \
                            handle_trap(ulMCAUSE, ulMEPC, ulMTVAL);                  \
                            ulHalNestedInterruptCounter--;                           \

/* Hook for tick. To use this, configUSE_TICK_HOOK must set to 1 */
void vApplicationTickHook( void )
{
    /* ALT_LOG - see altera_hal/HAL/inc/sys/alt_log_printf.h */
    ALT_LOG_SYS_CLK_HEARTBEAT();

    ulHalNestedInterruptCounter++;
    alt_tick();
    ulHalNestedInterruptCounter--;
}

/* Hook for idle task. To use this, configUSE_IDLE_HOOK must set to 1. */
void vApplicationIdleHook( void )
{

}

/* Hook for stack overflow. To use this, configCHECK_FOR_STACK_OVERFLOW must set
 * 1 or 2. 
 */
void vApplicationStackOverflowHook( TaskHandle_t xTask, char *pcTaskName )
{
    /*  To suspress unused argument warning. */
	( void ) xTask;

    printf("Stack overflow task is %s \r\n",pcTaskName);
    taskDISABLE_INTERRUPTS();
    __asm volatile( "ebreak" );
    for( ;; );
}

/* Hook for malloc failure. To use this, configUSE_MALLOC_FAILED_HOOK must set
 * to 1. 
 */
void vApplicationMallocFailedHook( void )
{

}

/* Override weak function defined in portASM.S */
void freertos_risc_v_application_interrupt_handler( void )
{
   HAL_HANDLE_TRAP();
}

/* Override weak function defined in portASM.S */
void freertos_risc_v_application_exception_handler( void )
{
   HAL_HANDLE_TRAP();
}
