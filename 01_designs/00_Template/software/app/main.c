/**
 * @file main.c
 * @brief Simple FreeRTOS example for the NIOS V soft-core processor.
 * * This file implements two basic FreeRTOS tasks that print messages
 * to the console with a fixed delay.
 *
 * @author Alexandre Magalhaes
 * @date Oct. 02nd, 2025
 */

#include <stdio.h>
#include <unistd.h>
#include "FreeRTOS.h"
#include "task.h"
#include "system.h"
#include "io.h"

/**
 * @brief Declaration for Task1, which prints a simple message.
 * @param parameters Unused pointer, required by FreeRTOS task signature.
 */
static void Task1 (void *parameters);

/**
 * @brief Declaration for Task2, which prints a simple message.
 * @param parameters Unused pointer, required by FreeRTOS task signature.
 */
static void Task2 (void *parameters);


/**
 * @brief Task 1 implementation. Prints a status message and delays.
 * @param parameters Unused pointer.
 */
static void Task1 (void *parameters)
{
    // Supress compiler warnings about unused parameters
    (void) parameters;

    while (1)
    {
        // Print message to the console
        printf("Running Task 1. \r\n");

        // Delay the task for 1000 milliseconds (1 second)
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    // Tasks created in this manner should never exit. 
    // If it did, it would be deleted here (though unreachable).
    vTaskDelete(NULL);  
}

/**
 * @brief Task 2 implementation. Prints a status message and delays.
 * @param parameters Unused pointer.
 */
static void Task2 (void *parameters)
{
    // Supress compiler warnings about unused parameters
    (void) parameters;
    
    while (1)
    {
        // Print message to the console
        printf("Running Task 2. \r\n");

        // Delay the task for 1000 milliseconds (1 second)
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    // Tasks created in this manner should never exit.
    // If it did, it would be deleted here (though unreachable).
    vTaskDelete(NULL);  
}

/**
 * @brief Main entry point of the application.
 * * Initializes the system and creates the FreeRTOS tasks before starting 
 * the scheduler.
 *
 * @return Returns 0 (unreachable in a typical embedded FreeRTOS application).
 */
int main (void)
{
    // Initial message printed upon application start
    printf("Starting NIOS V - FreeRTOS... \r\n");

    /** * @brief Create Task 1
     * @param Task1 Function to be executed
     * @param "Task1" Name of the task
     * @param 1024 Stack depth in words
     * @param NULL Task parameter (unused)
     * @param 2 Priority (higher number means higher priority)
     * @param NULL Task handle (unused)
     */
    xTaskCreate(Task1, "Task1", 1024, NULL, 2, NULL);
    
    /** * @brief Create Task 2
     * @param Task2 Function to be executed
     * @param "Task2" Name of the task
     * @param 1024 Stack depth in words
     * @param NULL Task parameter (unused)
     * @param 2 Priority (same as Task1 for round-robin scheduling)
     * @param NULL Task handle (unused)
     */
    xTaskCreate(Task2, "Task2", 1024, NULL, 2, NULL);

    // Start the FreeRTOS scheduler. This function will not return.
    vTaskStartScheduler();

    // Loop forever in case the scheduler fails to start (should not happen)
    for( ;; );

    // Return statement (unreachable code)
    return 0;
}
