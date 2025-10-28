/**
 * @file main.c
 * @brief
 * @author Alexandre Magalhaes
 * @date October 27th, 2025
 */

#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"
#include "system.h"
#include "io.h"
#include "adt7301.h"


/**
 * @brief
 * @param
 */
static void ReadSensorTask (void *parameters);

/**
 * @brief
 * @param
 */
static void ReadSensorTask (void *parameters)
{
    // Supress compiler warnings about unused parameters
    (void) parameters;

    // Temperature variable
    float temperature = 0.0f;

    while (1)
    {
        // Print message to the console
        printf("Running ReadSensorTask. \r\n");

        // Read sensor
        temperature = adt7301_read_temp();
        printf("temperature = %02f \r\n\n", temperature);

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

    /** * @brief Create Task Read Sensor
     * @param ReadSensorTask Function to be executed
     * @param "ReadSensorTask" Name of the task
     * @param 2048 Stack depth in words
     * @param NULL Task parameter (unused)
     * @param 2 Priority (higher number means higher priority)
     * @param NULL Task handle (unused)
     */
    xTaskCreate(ReadSensorTask, "ReadSensorTask", 2048, NULL, 2, NULL);

    // Start the FreeRTOS scheduler. This function will not return.
    vTaskStartScheduler();

    // Loop forever in case the scheduler fails to start (should not happen)
    for( ;; );

    // Return statement (unreachable code)
    return 0;
}
