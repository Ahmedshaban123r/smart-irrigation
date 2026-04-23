/*
 * Delay.h
 * Generic Software Delay Service
 * Hardware & Compiler Agnostic
 */

#ifndef DELAY_H
#define DELAY_H

#include "STD_TYPES.h"

/*
 * Generic software delay functions.
 * Does not rely on any compiler built-in macros.
 */
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);

#endif /* DELAY_H */