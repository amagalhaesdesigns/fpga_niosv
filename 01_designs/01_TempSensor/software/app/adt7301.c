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
    uint8_t dataTx[1] = {0x00};
    uint8_t dataRx[2] = {0x00, 0x00};
    uint16_t adcCode = 0;
    float temperature = 0.0f;

    (void)alt_avalon_spi_command(ADT7301_BASE, 0, 1, dataTx, 1, dataRx, 0);

    adcCode = (dataRx[1] << 8) | (dataRx[0]);

    temperature = (adcCode & 0x2000) ?
        (adcCode - 16384) / 32.0f :
        (adcCode / 32.0f);

    return temperature;
}
