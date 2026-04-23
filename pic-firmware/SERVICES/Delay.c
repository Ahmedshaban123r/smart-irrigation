/*
 * Delay.c
 * Generic Software Delay Service Implementation
 * Calibrated roughly for 8 MHz F_OSC
 */

#include "Delay.h"

void Generic_Delay_ms(u16 ms)
{
    /* 'volatile' prevents the compiler from optimizing the loop away */
    volatile u16 i, j;
    
    for(i = 0; i < ms; i++)
    {
        /* Magic number ~180 is roughly 1ms at 8MHz in standard C.
         * Tune this up or down if your Proteus simulation runs too fast/slow. 
         */
        for(j = 0; j < 180; j++)
        {
            /* Do nothing */
        }
    }
}

void Generic_Delay_us(u16 us)
{
    volatile u16 i, j;
    
    for(i = 0; i < us; i++)
    {
        /* Software delays for microseconds are inherently inaccurate in C.
         * A tiny loop to waste ~1us of clock cycles at 8MHz.
         */
        for(j = 0; j < 2; j++)
        {
            /* Do nothing */
        }
    }
}