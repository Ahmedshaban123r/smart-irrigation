/*
 * Relay.c
 * Pump relay on RD0 — ACTIVE LOW (LOW=ON, HIGH=OFF).
 * All PORTD writes go through portd_shadow to preserve LCD bits RD2-RD7.
 */

#include "Relay_interface.h"
#include "Relay_private.h"
#include "../../config.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../../SERVICES/STD_TYPES.h"

extern volatile u8 portd_shadow;

void Relay_Init(void)
{
    CLR_BIT(RELAY_TRIS, RELAY_PIN);        /* RD0 output */
    portd_shadow |= (u8)(1u << RELAY_PIN); /* pump OFF at startup (HIGH) */
    PORTD = portd_shadow;
}

void Relay_On(void)
{
    portd_shadow &= (u8)(~(u8)(1u << RELAY_PIN)); /* LOW = pump ON */
    PORTD = portd_shadow;
}

void Relay_Off(void)
{
    portd_shadow |= (u8)(1u << RELAY_PIN); /* HIGH = pump OFF */
    PORTD = portd_shadow;
}

u8 Relay_GetState(void)
{
    return (u8)((portd_shadow >> RELAY_PIN) & 1u); /* read shadow, not pin */
}
