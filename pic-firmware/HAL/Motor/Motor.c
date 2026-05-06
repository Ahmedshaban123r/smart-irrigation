/*
 * Motor.c
 * A4988 stepper driver, 1/16 microstepping.
 * RC0=STEP, RC1=DIR (HIGH=away from home), RC2=ENABLE (LOW=on).
 * RB3=limit switch (active LOW) marks home position.
 * Button polled every 50 steps inside move loops to catch e-stop.
 */

#include "../../config.h"
#include "Motor_interface.h"
#include "../Button/Button_interface.h"
#include "../../MCAL/MCU_Registers.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../../SERVICES/STD_TYPES.h"

static s32 current_position = 0;

static const u32 plant_positions[NUM_PLANTS] = {4000u, 12000u, 20000u, 28000u, 36000u};

static void step_once(u8 delay_ms)
{
    u8 i;
    SET_BIT(PORTC, PIN_STEP);
    __delay_us(2);
    CLR_BIT(PORTC, PIN_STEP);
    __delay_us(2);
    for(i = 0u; i < delay_ms; i++) { __delay_ms(1); }
}

void Motor_Home(void)
{
    u32 backoff;
    u16 poll_cnt = 0u;

    /* Enable driver */
    CLR_BIT(PORTC, PIN_ENABLE);

    /* Drive toward home (DIR=LOW = toward home) */
    CLR_BIT(PORTC, PIN_DIR);

    while(GET_BIT(PORTB, PIN_LIMIT))   /* limit = HIGH when not triggered */
    {
        step_once(STEP_DELAY_HOMING_MS);
        poll_cnt++;
        if((poll_cnt & 0x31u) == 0u) {
            Button_Poll();
            if(Button_IsEstopped()) {
                Motor_Disable();
                return;
            }
        }
    }

    /* Back off from switch */
    SET_BIT(PORTC, PIN_DIR);
    for(backoff = 0u; backoff < HOMING_BACKOFF_STEPS; backoff++) {
        step_once(STEP_DELAY_HOMING_MS);
    }

    current_position = 0;
    CLR_BIT(PORTC, PIN_DIR);
}

void Motor_MoveTo(u8 plant_index)
{
    s32 target, delta;
    u32 steps;
    u16 poll_cnt = 0u;

    if(plant_index >= NUM_PLANTS) return;

    target = (s32)plant_positions[plant_index];
    delta  = target - current_position;
    steps  = (delta < 0) ? (u32)(-delta) : (u32)delta;

    CLR_BIT(PORTC, PIN_ENABLE);

    if(delta > 0) SET_BIT(PORTC, PIN_DIR);
    else          CLR_BIT(PORTC, PIN_DIR);

    while(steps > 0u)
    {
        step_once(STEP_DELAY_NORMAL_MS);
        steps--;
        current_position += (delta > 0) ? 1 : -1;
        poll_cnt++;
        if((poll_cnt % 50u) == 0u) {
            Button_Poll();
            if(Button_IsEstopped()) {
                Motor_Disable();
                return;
            }
        }
    }
}

void Motor_Disable(void)
{
    SET_BIT(PORTC, PIN_ENABLE);   /* HIGH = disabled */
}
