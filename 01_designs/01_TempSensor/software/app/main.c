/**
 * @file main.c
 * @brief Example FreeRTOS application for temperature acquisition using ADT7301.
 *
 * This example demonstrates:
 *  - Reading temperature samples from an ADT7301 sensor via SPI.
 *  - Applying a simple moving average filter.
 *  - Exchanging data between two tasks using a FreeRTOS queue.
 *  - Implementing a basic producer–consumer architecture.
 *
 * The Producer Task acquires and filters temperature samples,
 * while the Consumer Task receives and prints them.
 *
 * @author
 *  Alexandre Magalhães
 * @date
 *  October 27th, 2025
 */

#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "system.h"
#include "io.h"
#include "adt7301.h"

/** @brief Maximum queue length (number of temperature packets). */
#define QUEUE_LENGTH     (10)

/** @brief Moving Average filter window length. */
#define FILTER_LENGHT    (50)

/**
 * @struct TemperaturePacket_t
 * @brief Structure representing one temperature data packet.
 *
 * Each packet includes:
 *  - Raw sensor data (direct from ADT7301).
 *  - Filtered data (moving average).
 *  - A buffer of recent samples.
 *  - Timestamp (in FreeRTOS ticks).
 */
typedef struct
{
    float raw_value;                     /**< Raw temperature value read from the ADT7301. */
    float filtered_value;                /**< Filtered temperature value (moving average). */
    float raw_buffer[FILTER_LENGHT];     /**< Circular buffer storing recent raw samples. */
    uint32_t timestamp;                  /**< Timestamp of the current sample (FreeRTOS tick count). */
} TemperaturePacket_t;

/** @brief Global handle for the FreeRTOS temperature data queue. */
QueueHandle_t xTemperatureQueue;

/* === Local Function Prototypes === */
static void vProducerTask(void *parameters);
static void vConsumerTask(void *parameters);

/**
 * @brief Producer Task — acquires and filters temperature data.
 *
 * This task periodically reads temperature data from the ADT7301 sensor,
 * applies a moving average filter, and sends the processed data to the
 * FreeRTOS queue. It represents the data acquisition stage in a typical
 * embedded signal-processing system.
 *
 * @param[in] parameters Pointer to optional parameters (unused).
 */
static void vProducerTask(void *parameters)
{
    (void) parameters;  /* Suppress compiler warnings */

    TemperaturePacket_t xPacket;          /* Local packet instance. */
    uint32_t i = 0;                       /* Loop index. */
    uint32_t ulSampleIndex = 0;           /* Circular buffer index. */
    uint32_t ulSampleCount = 0;           /* Sample counter. */
    const TickType_t xDelay = pdMS_TO_TICKS(250);  /* Sampling interval: 250ms. */

    /* Initialize circular buffer to zero */
    for (i = 0; i < FILTER_LENGHT; i++)
    {
        xPacket.raw_buffer[i] = 0.0f;
    }

    /* === Main Acquisition Loop === */
    for( ;; )
    {
        /** Step 1: Acquire data from the ADT7301 sensor. */
        xPacket.raw_value = adt7301_read_temp();

        /** Step 2: Insert the new sample into the circular buffer. */
        xPacket.raw_buffer[ulSampleIndex] = xPacket.raw_value;

        /** Step 3: Compute the moving average. */
        xPacket.filtered_value = 0.0f;
        for (i = 0; i < FILTER_LENGHT; i++)
        {
            xPacket.filtered_value += xPacket.raw_buffer[i];
        }
        xPacket.filtered_value /= FILTER_LENGHT;

        /** Step 4: Timestamp the current sample. */
        xPacket.timestamp = xTaskGetTickCount();

        /** Step 5: Print debug info to console. */
        printf("PRODUCER: Sample %lu | Raw: %.2f | Filtered: %.2f\n",
               ulSampleCount,
               xPacket.raw_value,
               xPacket.filtered_value);

        /** Step 6: Send the processed packet to the queue. */
        if (xQueueSend(xTemperatureQueue, &xPacket, xDelay) != pdPASS)
        {
            printf("PRODUCER: ERROR — Temperature queue is full.\n");
        }

        /** Step 7: Update buffer index and sample counter. */
        ulSampleIndex = (ulSampleIndex + 1) % FILTER_LENGHT;
        ulSampleCount++;

        /** Step 8: Delay until the next acquisition cycle. */
        vTaskDelay(xDelay);
    }

    /* Tasks should not return. If they do, delete for safety. */
    vTaskDelete(NULL);
}

/**
 * @brief Consumer Task — receives and processes temperature data.
 *
 * This task waits for data packets from the queue and processes them.
 * In this simple example, it just prints the received filtered temperature
 * and timestamp to the console.
 *
 * @param[in] parameters Pointer to optional parameters (unused).
 */
static void vConsumerTask(void *parameters)
{
    (void) parameters;  /* Suppress unused warning */

    TemperaturePacket_t xReceivedPacket;

    /* === Main Reception Loop === */
    for (;;)
    {
        /** Wait indefinitely for a packet to arrive. */
        if (xQueueReceive(xTemperatureQueue, &xReceivedPacket, portMAX_DELAY) == pdPASS)
        {
            /** Step 1: Packet successfully received. */
            printf("CONSUMER: Received filtered temp: %.2fC @ Tick: %lu\n",
                   xReceivedPacket.filtered_value,
                   xReceivedPacket.timestamp);
        }
    }
}

/**
 * @brief Main entry point of the application.
 *
 * Initializes the system, creates the FreeRTOS queue, starts the producer
 * and consumer tasks, and launches the scheduler. This function should
 * never return during normal operation.
 *
 * @return Always returns 0 (unreachable in FreeRTOS applications).
 */
int main(void)
{
    printf("Starting NIOS V - FreeRTOS...\r\n");

    /** Step 1: Create the temperature data queue. */
    xTemperatureQueue = xQueueCreate(QUEUE_LENGTH, sizeof(TemperaturePacket_t));

    if (xTemperatureQueue != NULL)
    {
        printf("Temperature queue created successfully.\n");

        /** Step 2: Create the Producer Task.
         *  @note Priority 2 ensures timely sampling.
         */
        xTaskCreate(vProducerTask, "Producer", 2048, NULL, 2, NULL);

        /** Step 3: Create the Consumer Task.
         *  @note Lower or equal priority (2) — non-time-critical.
         */
        xTaskCreate(vConsumerTask, "Consumer", 2048, NULL, 2, NULL);

        /** Step 4: Start the FreeRTOS scheduler (never returns). */
        vTaskStartScheduler();
    }
    else
    {
        printf("ERROR: Failed to create temperature queue.\n");
    }

    /** Step 5: Fallback infinite loop (should never execute). */
    for (;;);

    /* Unreachable code (kept for compliance). */
    return 0;
}
