/*
 * Humidity_interface.h
 * Irrigation Project — DHT11/DHT22 Humidity Sensor Public API
 */

#ifndef HUMIDITY_INTERFACE_H
#define HUMIDITY_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

#define HUMIDITY_OK      0u
#define HUMIDITY_ERROR   1u

/*
 * Humidity_Init()
 * Configures the DHT pin as an input by default so it stays HIGH
 * via the internal or external pull-up resistor.
 */
void Humidity_Init(void);

/*
 * Humidity_Read()
 * Bit-bangs the 1-wire protocol to fetch the 40-bit packet.
 * Returns HUMIDITY_OK on success, and fills the pointers.
 * Returns HUMIDITY_ERROR on timeout or checksum mismatch.
 */
u8 Humidity_Read(void);

#endif /* HUMIDITY_INTERFACE_H */