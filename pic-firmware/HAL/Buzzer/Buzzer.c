/*
 * Buzzer.c
 * Irrigation Project � Buzzer Driver
 * Target: PIC16F877A | Compiler Agnostic
 */

#include "Buzzer_interface.h"
#include "Buzzer_private.h"
#include "../../MCAL/MCU_Registers.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../../SERVICES/STD_TYPES.h"

/* Notice: Buzzer_Delay_ms() wrapper has been completely removed! */

void Buzzer_Init(void)
{
    CLR_BIT(BUZZER_TRIS, BUZZER_PIN); /* Output */
    CLR_BIT(BUZZER_PORT, BUZZER_PIN); /* LOW */
}

void Buzzer_On(void)
{
    SET_BIT(BUZZER_PORT, BUZZER_PIN);
}

void Buzzer_Off(void)
{
    CLR_BIT(BUZZER_PORT, BUZZER_PIN);
}

void Buzzer_Beep(u16 duration_ms)
{
    Buzzer_On();
    __delay_ms(duration_ms); /* Using generic delay */
    Buzzer_Off();
}

void Buzzer_BeepN(u8 count, u16 ms_on, u16 ms_off)
{
    u8 i = 0u;
    for(i = 0u; i < count; i++)
    {
        Buzzer_On();
        __delay_ms(ms_on); /* Using generic delay */
        Buzzer_Off();

        if(i < (u8)(count - 1u))
        {
            __delay_ms(ms_off); /* Using generic delay */
        }
    }
}