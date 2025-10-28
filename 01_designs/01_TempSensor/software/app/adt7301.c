/*
 * adt7301.c
 *
 *  Created on: 27 de out. de 2025
 *      Author: Alexandre Magalhaes
 */

#include "system.h"
#include "altera_avalon_spi.h"
#include "adt7301.h"

float adt7301_read_temp(void)
{
	const uint32_t write_length = 0;
	const uint8_t *write_data = NULL;
	uint8_t dataRx[2];
    uint16_t adcCode = 0;
    float fTemp = 0.0f;

    (void)alt_avalon_spi_command(ADT7301_BASE, 0, write_length, write_data, sizeof(dataRx), dataRx, 0);

    adcCode = (dataRx[0] << 8) | (dataRx[1]);

    fTemp = (adcCode & 0x2000) ?
        (adcCode - 16384) / 32.0f :
        (adcCode / 32.0f);

    return (fTemp);
}
