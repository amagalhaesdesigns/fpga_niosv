#ifndef __ALT_FLAG_UCOSII_H__
#define __ALT_FLAG_UCOSII_H__

/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2022 Intel Corporation, San Jose, California, USA.           *
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
******************************************************************************/

/*
 * This file provides the FreeRTOS specific functions used to implement the 
 * macros in alt_flag.h. These functions are simply wrappers for the FreeRTOS
 * flags API.
 *
 * These functions are considered to be part of the internal implementation of
 * the HAL, and should not be called directly by application code or device
 * drivers. They are not guaranteed to be preserved in future versions of the
 * HAL.
 */

#include "FreeRTOS.h"
#include "event_groups.h"
#include "os_cpu.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * alt_flag_create() is a wrapper for OSFlagCreate(), with the error code 
 * converted into the functions return value.
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_flag_create (EventGroupHandle_t* pgroup)
{
  *pgroup = xEventGroupCreate();
  return *pgroup != NULL? 0 : -1;
}

/*
 * alt_flag_pend() is a wrapper for xEventGroupWaitBits(), with the error code 
 * converted into the functions return value.
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_flag_pend (EventGroupHandle_t group, 
                   EventBits_t flags, 
                   BaseType_t  wait_types,
                   TickType_t  timeout)
{
  int ret = 0;
  EventBits_t uxBits;
  if (taskSCHEDULER_RUNNING == xTaskGetSchedulerState())
  {
    uxBits = xEventGroupWaitBits(group, flags, ( wait_types & 0x2 ) >> 1,
                                ( wait_types & 0x1 ), timeout);
    ret = uxBits & flags? 0 : -1;
  }
  return ret;
}

/*
 * alt_flag_post() is a wrapper for xEventGroup[Set|Clear]Bits() or
 * xEventGroup[Set|Clear]BitsFromISR().
 */

static ALT_INLINE int ALT_ALWAYS_INLINE alt_flag_post (EventGroupHandle_t group, 
                   EventBits_t     flags, 
                   uint8_t        opt)
{
  BaseType_t xHigherPriorityTaskWoken = pdFALSE;
  if (taskSCHEDULER_RUNNING == xTaskGetSchedulerState())
  {
    if (IS_IN_ISR_CONTEXT()){
      if (opt == 1){ 
        if ( pdTRUE == xEventGroupSetBitsFromISR(group, flags, &xHigherPriorityTaskWoken)){
          portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
        }
      } else {
        xEventGroupClearBitsFromISR(group, flags);     
      }
    } else {
      if (opt == 1){ 
        xEventGroupSetBits(group, flags);
      } else {
        xEventGroupClearBits(group, flags);     
      }      
    }
  }
  return 0;
}

#ifdef __cplusplus
}
#endif

#endif /* __ALT_FLAG_UCOSII_H__ */
