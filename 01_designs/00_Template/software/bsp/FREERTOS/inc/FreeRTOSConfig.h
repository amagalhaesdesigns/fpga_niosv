/*
 * FreeRTOS V10.5.0
 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * http://www.FreeRTOS.org
 * http://aws.amazon.com/freertos
 *
 * 1 tab == 4 spaces!
 */

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#include "sys/alt_tls.h"

#include "system.h"
#include "os_cpu.h"

/*-----------------------------------------------------------
 * Application specific definitions.
 *
 * These definitions should be adjusted for your particular hardware and
 * application requirements.
 *
 * THESE PARAMETERS ARE DESCRIBED WITHIN THE 'CONFIGURATION' SECTION OF THE
 * FreeRTOS API DOCUMENTATION AVAILABLE ON THE FreeRTOS.org WEB SITE.
 *
 * See http://www.freertos.org/a00110.html.
 *----------------------------------------------------------*/
#define configMTIME_BASE_ADDRESS            ( ALT_CPU_MTIME_OFFSET + 0x8UL )
#define configMTIMECMP_BASE_ADDRESS         ( ALT_CPU_MTIME_OFFSET )
#define configTICK_RATE_HZ                  ( ( TickType_t ) ALT_CPU_TICKS_PER_SEC )
#define configCPU_CLOCK_HZ                  ( ALT_CPU_FREQ )
#define configUSE_PREEMPTION                OS_USE_PREEMPTION
#define configMAX_PRIORITIES                ( OS_MAX_PRIORITIES )
#define configMINIMAL_STACK_SIZE            ( ( unsigned short ) OS_MIN_STACK_SIZE )
#define configSUPPORT_DYNAMIC_ALLOCATION	OS_MEMORY_DYNAMIC_ALLOCATION_EN
#define configTOTAL_HEAP_SIZE               ( ( size_t ) OS_TOTAL_HEAP_SIZE )
#define configMAX_TASK_NAME_LEN             ( OS_MAX_TASK_NAME_LEN )
#define configUSE_MUTEXES                   OS_MUTEX_EN
#define configUSE_QUEUE_SETS                OS_USE_QUEUE_SETS
#define configQUEUE_REGISTRY_SIZE           OS_Q_REG_SIZE
#define configUSE_RECURSIVE_MUTEXES         OS_RECURSIVE_MUTEX_EN
#define configUSE_COUNTING_SEMAPHORES       OS_COUNTING_SEM_EN
#define configUSE_TRACE_FACILITY            OS_USE_TRACE_FACILITY
#define configIDLE_SHOULD_YIELD             OS_IDLE_SHOULD_YEILD
#define configUSE_16_BIT_TICKS              OS_USE_16_BIT_TICKS

#ifdef ALT_STACK_CHECK
    #define configRECORD_STACK_HIGH_ADDRESS 1
#endif

/* Thread local support */
#define configUSE_C_RUNTIME_TLS_SUPPORT 1

#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
    #include <reent.h>
#endif

typedef struct {
    char _tls_content[OS_TLS_BYTES_PER_TASK];
#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
    struct _reent _impure_ptr;
#endif
} __tls_block_type;

#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
    // TLS + Newlib reentrancy support
    #define configTLS_BLOCK_TYPE __tls_block_type
    #define configINIT_TLS_BLOCK( xTLSBlock ) alt_init_tls_block((void *)(&(xTLSBlock._tls_content)));      \
                                              _REENT_INIT_PTR( &(xTLSBlock._impure_ptr) );
    #define configSET_TLS_BLOCK( xTLSBlock ) alt_set_thread_pointer((void *)(&(xTLSBlock._tls_content)));   \
                                             _impure_ptr = &(xTLSBlock._impure_ptr);
    #define configDEINIT_TLS_BLOCK( xTLSBlock ) _reclaim_reent( &(xTLSBlock._impure_ptr) )
#else
    // Just TLS
    #define configTLS_BLOCK_TYPE __tls_block_type
    #define configINIT_TLS_BLOCK( xTLSBlock ) alt_init_tls_block((void *)(&(xTLSBlock._tls_content)))
    #define configSET_TLS_BLOCK( xTLSBlock ) alt_set_thread_pointer((void *)(&(xTLSBlock._tls_content)))
    #define configDEINIT_TLS_BLOCK( xTLSBlock ) // Nothing for now
#endif

/* Software timer definitions. */
#define configUSE_TIMERS                    OS_USE_TIMERS
#define configTIMER_TASK_PRIORITY           ( configMAX_PRIORITIES - 1 )
#define configTIMER_QUEUE_LENGTH            OS_TIMER_QUEUE_LEN
#define configTIMER_TASK_STACK_DEPTH        ( OS_TIMER_TASK_DEPTH )

/* Hook function related definitions. */
#define configUSE_IDLE_HOOK                 OS_USE_IDLE_HOOK
#define configUSE_TICK_HOOK                 OS_USE_TICK_HOOK
#define configCHECK_FOR_STACK_OVERFLOW      OS_CHECK_STACK_OVERFLOW
#define configUSE_MALLOC_FAILED_HOOK        OS_MALLOC_FAILED_HOOK_EN


/* Set the following definitions to 1 to include the API function, or zero
to exclude the API function. */
#define INCLUDE_vTaskPrioritySet		    OS_TASK_PRIORITY_SET_EN
#define INCLUDE_uxTaskPriorityGet			OS_TASK_PRIORITY_GET_EN
#define INCLUDE_vTaskDelete					OS_TASK_DELETE_EN
#define INCLUDE_vTaskCleanUpResources		OS_TASK_CLEAN_UP_RESOURCES_EN
#define INCLUDE_vTaskSuspend				OS_TASK_SUSPEND_EN
#define INCLUDE_vTaskDelayUntil				OS_TASK_DELAY_UNTIL_EN
#define INCLUDE_vTaskDelay					OS_TASK_DELAY_EN
#define INCLUDE_eTaskGetState				OS_TASK_GET_STATE_EN
#define INCLUDE_xTimerPendFunctionCall		OS_TIMER_PEND_FUNCTION_CALL_EN
#define INCLUDE_xTaskAbortDelay				OS_TASK_ABORT_DELAY_EN
#define INCLUDE_xTaskGetHandle				OS_TASK_GET_HANDLE_EN
#define INCLUDE_xSemaphoreGetMutexHolder	OS_SEMAPHORE_GET_MUTEX_HOLDER_EN

/* Normal assert() semantics without relying on the provision of an assert.h
header file. */
#define configASSERT( x )                   if( ( x ) == 0 ) {                 \
                                                taskDISABLE_INTERRUPTS();      \
                                                __asm volatile( "ebreak" );    \
                                                for( ;; );                     \
                                            }                                  \

#endif /* FREERTOS_CONFIG_H */
