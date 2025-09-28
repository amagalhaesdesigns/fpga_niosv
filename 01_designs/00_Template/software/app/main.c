#include <stdio.h>
#include <unistd.h>
#include "FreeRTOS.h"
#include "task.h"
#include "system.h"
#include "io.h"

static void Task1 (void *parameters);
static void Task2 (void *parameters);


static void Task1 (void *parameters)
{
	while (1)
	{
		printf("Running task 1 \r\n");

		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	vTaskDelete(NULL);	
}

static void Task2 (void *parameters)
{
	while (1)
	{
		printf("Running task 2 \r\n");

		vTaskDelay(1000 / portTICK_PERIOD_MS);
	}

	vTaskDelete(NULL);	
}

int main (void)
{
	printf("Starting NIOS V - FreeRTOS... \r\n");

	xTaskCreate(Task1, "Task1", 1024, NULL, 2, NULL);
	xTaskCreate(Task2, "Task2", 1024, NULL, 2, NULL);

	vTaskStartScheduler();

	for( ;; );

	return 0;
}
