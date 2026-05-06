/*
 * Safety_interface.h
 * Irrigation Project — Safety Monitor Public API
 */

#ifndef SAFETY_INTERFACE_H
#define SAFETY_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

/* -- System States -- */
#define SAFETY_STATE_NORMAL   0u
#define SAFETY_STATE_WARNING  1u
#define SAFETY_STATE_FAULT    2u

/* -- Fault source bitmask (OR-able) -- */
#define SAFETY_FAULT_NONE       0x00u
#define SAFETY_FAULT_OVERWATER  0x01u   /* Bit 0: overwatering (soil>95%) */
#define SAFETY_FAULT_OVERCURR   0x02u   /* Bit 1: overcurrent (>150%)     */
#define SAFETY_FAULT_OVERHEAT   0x04u   /* Bit 2: overheat (>55°C)        */

void Safety_Init(void);
void Safety_CheckSoilMoisture(void);
void Safety_CheckOvercurrent(void);
void Safety_CheckTemperature(void);
u8   Safety_IsLocked(void);
u8   Safety_GetFaultFlags(void);
u8   Safety_GetState(void);
void Safety_ManualReset(void);
void Safety_Run(void);

#endif /* SAFETY_INTERFACE_H */