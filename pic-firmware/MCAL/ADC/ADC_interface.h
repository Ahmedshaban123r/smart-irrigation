/*
 * ADC_interface.h
 * Irrigation Project — ADC Driver Public API
 *
 * Supports: LM35 (AN1), ACS712 (AN2), Soil Moisture (AN0)
 */

#ifndef ADC_INTERFACE_H
#define ADC_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

/* ── Channel IDs (match schematic AN pins) ── */
#define ADC_CHANNEL_SOIL     0u   /* RA0/AN0 — Soil Moisture Sensor  */
#define ADC_CHANNEL_TEMP     1u   /* RA1/AN1 — LM35 Temperature      */
#define ADC_CHANNEL_CURRENT  2u   /* RA2/AN2 — ACS712 Current Sensor */

/*
 * ADC_Init()
 *   Configure ADCON0, ADCON1, TRISA for all three analog channels.
 *   Call once at startup before any ADC_Read().
 */
void ADC_Init(void);

/*
 * ADC_Read(channel) → u16  [0..1023]
 *   Blocking read: selects channel, waits acquisition delay,
 *   starts conversion, waits for GO/DONE to clear, returns 10-bit result.
 *
 *   channel: ADC_CHANNEL_SOIL / ADC_CHANNEL_TEMP / ADC_CHANNEL_CURRENT
 */
u16 ADC_Read(u8 channel);

/*
 * ADC_ReadAverage(channel, samples) → u16
 *   Returns the average of 'samples' consecutive readings.
 *   Use for noisy signals (current sensor especially).
 *   Recommended: samples = 8 for current, 4 for temp/soil.
 */
u16 ADC_ReadAverage(u8 channel, u8 samples);

#endif /* ADC_INTERFACE_H */
