/*
 * Safety.c
 * Irrigation Project ? Safety Monitor Implementation
 */

#include "Safety_interface.h"
#include "Safety_config.h"
#include "../../HAL/Current/Current_interface.h"
#include "../../HAL/Humidity/Humidity_interface.h"
#include "../../HAL/Soil/Soil_interface.h"
#include "../../HAL/Temperature/Temp_interface.h"
#include "../../HAL/Relay/Relay_interface.h"
#include "../../HAL/LED/LED_interface.h"
#include "../../HAL/LCD/LCD_interface.h"
#include "../../HAL/Buzzer/Buzzer_interface.h"
#include "../../MCAL/GPIO/GPIO_interface.h"
#include "../../MCAL/MCU_Registers.h"
#include "../../SERVICES/STD_TYPES.h"

static u8  safety_state        = SAFETY_STATE_NORMAL;
static u8  safety_fault_flags  = SAFETY_FAULT_NONE;
static u8  overcurr_count      = 0u;
static u8  manual_reset_needed = 0u;

static u8  pump_locked_overwater = 0u;
static u8  pump_locked_overcurr  = 0u;
static u8  pump_locked_overheat  = 0u;

static u16 tick_soil    = 0u;
static u16 tick_temp    = 0u;

static u8 lcd_last_soil    = 0u;
static u8 lcd_last_current = 0u;
static u8 lcd_last_temp    = 0u;

static void update_system_state(void)
{
    if(safety_fault_flags != SAFETY_FAULT_NONE) {
        safety_state = SAFETY_STATE_FAULT;
    } else if(pump_locked_overwater || pump_locked_overcurr || pump_locked_overheat) {
        safety_state = SAFETY_STATE_WARNING;
    } else {
        safety_state = SAFETY_STATE_NORMAL;
    }
}

static void emergency_shutdown_all(void)
{
    Relay_Off();
    LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
    LED_On(LED_RED_PORT, LED_RED_PIN);
    Buzzer_BeepN(3u, 500u, 200u);
}

void Safety_Init(void)
{
    safety_state        = SAFETY_STATE_NORMAL;
    safety_fault_flags  = SAFETY_FAULT_NONE;
    overcurr_count      = 0u;
    manual_reset_needed = 0u;
    pump_locked_overwater = 0u;
    pump_locked_overcurr  = 0u;
    pump_locked_overheat  = 0u;
    tick_soil  = 0u;
    tick_temp  = 0u;

    lcd_last_soil    = 0u;
    lcd_last_current = 0u;
    lcd_last_temp    = 0u;

    /* FIXED: Using _PORT instead of _TRIS to correctly interface with LED.c */
    LED_Init(LED_YELLOW_PORT, LED_YELLOW_PIN);
    LED_Init(LED_RED_PORT,    LED_RED_PIN);
    LED_Off(LED_YELLOW_PORT,  LED_YELLOW_PIN);
    LED_Off(LED_RED_PORT,     LED_RED_PIN);
}

void Safety_CheckSoilMoisture(void)
{
    u8 soil_pct = Soil_Read_Pct();
    u8 new_state = 0u;

    if(soil_pct > SAFETY_SOIL_CRITICAL_PCT) new_state = 2u;
    else if(soil_pct > SAFETY_SOIL_WARN_PCT) new_state = 1u;
    else new_state = 0u;

    if(new_state == 2u)
    {
        if(!manual_reset_needed) {
            Relay_Off();
            pump_locked_overwater = 1u;
            safety_fault_flags |= SAFETY_FAULT_OVERWATER;
        }
        LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
        LED_On(LED_RED_PORT, LED_RED_PIN);

        if(lcd_last_soil != 2u) {
            Buzzer_BeepN(2u, 300u, 100u);
            LCD_Clear();
            LCD_GoToRowCol(1u, 1u);
            LCD_SendString_Const("! OVERWATER FALT");
        }
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("Soil:");
        LCD_SendNumber((s16)soil_pct);
        LCD_SendString_Const("%        ");
    }
    else if(soil_pct <= SAFETY_SOIL_RECOVERY_PCT && (safety_fault_flags & SAFETY_FAULT_OVERWATER))
    {
        safety_fault_flags   &= ~SAFETY_FAULT_OVERWATER;
        pump_locked_overwater  = 0u;
        new_state = 0u;

        LED_Off(LED_RED_PORT, LED_RED_PIN);
        LCD_Clear();
        LCD_GoToRowCol(1u, 1u);
        LCD_SendString_Const("Soil Recovered  ");
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("Soil:");
        LCD_SendNumber((s16)soil_pct);
        LCD_SendString_Const("%        ");
    }
    else if(new_state == 1u)
    {
        LED_On(LED_YELLOW_PORT, LED_YELLOW_PIN);
        if(lcd_last_soil != 1u) {
            Buzzer_Beep(100u);
            LCD_Clear();
            LCD_GoToRowCol(1u, 1u);
            LCD_SendString_Const("SOIL SATURATED  ");
        }
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("Soil:");
        LCD_SendNumber((s16)soil_pct);
        LCD_SendString_Const("%        ");
    }
    else
    {
        if(!(safety_fault_flags & SAFETY_FAULT_OVERWATER)) {
            pump_locked_overwater = 0u;
            LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
        }
    }

    lcd_last_soil = new_state;
    update_system_state();
}

void Safety_CheckOvercurrent(void)
{
    s16 current_ma = Current_Read_mA();
    u16 abs_ma = (current_ma < 0) ? (u16)(-current_ma) : (u16)current_ma;
    u8  new_state = 0u;

    if(abs_ma > SAFETY_CURRENT_CRITICAL_MA)
    {
        new_state = 2u;
        if(!manual_reset_needed) {
            emergency_shutdown_all();
            pump_locked_overcurr  = 1u;
            safety_fault_flags   |= SAFETY_FAULT_OVERCURR;
            manual_reset_needed   = 1u;
            overcurr_count        = 0u;
        }

        if(lcd_last_current != 2u) {
            LCD_Clear();
            LCD_GoToRowCol(1u, 1u);
            LCD_SendString_Const("! OVERCURR FAULT");
        }
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("I:");
        LCD_SendNumber((s16)abs_ma);
        LCD_SendString_Const("mA LOCKED  ");
    }
    else if(abs_ma > SAFETY_CURRENT_WARN_MA)
    {
        new_state = 1u;
        overcurr_count++;

        if(overcurr_count >= SAFETY_CURRENT_PERSIST_CNT) {
            LED_On(LED_YELLOW_PORT, LED_YELLOW_PIN);
            if(lcd_last_current != 1u) {
                Buzzer_Beep(200u);
                LCD_Clear();
                LCD_GoToRowCol(1u, 1u);
                LCD_SendString_Const("HIGH CURRENT!   ");
            }
            LCD_GoToRowCol(2u, 1u);
            LCD_SendString_Const("I:");
            LCD_SendNumber((s16)abs_ma);
            LCD_SendString_Const("mA     ");
        }
    }
    else
    {
        new_state      = 0u;
        overcurr_count = 0u;
        if(!(safety_fault_flags & SAFETY_FAULT_OVERCURR)) {
            pump_locked_overcurr = 0u;
            LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
        }
    }

    lcd_last_current = new_state;
    update_system_state();
}

void Safety_CheckTemperature(void)
{
    s16 temp_c = Temp_Read_C();
    u8  new_state = 0u;

    if(temp_c > SAFETY_TEMP_CRITICAL_C) new_state = 2u;
    else if(temp_c > SAFETY_TEMP_WARN_C) new_state = 1u;
    else new_state = 0u;

    if(new_state == 2u)
    {
        if(!manual_reset_needed) {
            emergency_shutdown_all();
            pump_locked_overheat = 1u;
            safety_fault_flags  |= SAFETY_FAULT_OVERHEAT;
        }

        if(lcd_last_temp != 2u) {
            LCD_Clear();
            LCD_GoToRowCol(1u, 1u);
            LCD_SendString_Const("! OVERHEAT FAULT");
        }
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("T:");
        LCD_SendNumber((s16)temp_c);
        LCD_SendString_Const("C SHUTDOWN  ");
    }
    else if(temp_c <= SAFETY_TEMP_RECOVERY_C && (safety_fault_flags & SAFETY_FAULT_OVERHEAT))
    {
        safety_fault_flags  &= ~SAFETY_FAULT_OVERHEAT;
        pump_locked_overheat = 0u;
        new_state = 0u;

        LED_Off(LED_RED_PORT, LED_RED_PIN);
        LCD_Clear();
        LCD_GoToRowCol(1u, 1u);
        LCD_SendString_Const("Temp Recovered  ");
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("T:");
        LCD_SendNumber((s16)temp_c);
        LCD_SendString_Const("C OK    ");
    }
    else if(new_state == 1u)
    {
        LED_On(LED_YELLOW_PORT, LED_YELLOW_PIN);
        if(lcd_last_temp != 1u) {
            Buzzer_Beep(150u);
            LCD_Clear();
            LCD_GoToRowCol(1u, 1u);
            LCD_SendString_Const("HIGH TEMP WARN  ");
        }
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("T:");
        LCD_SendNumber((s16)temp_c);
        LCD_SendString_Const("C       ");
    }
    else
    {
        if(!(safety_fault_flags & SAFETY_FAULT_OVERHEAT)) {
            pump_locked_overheat = 0u;
            LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
        }
    }

    lcd_last_temp = new_state;
    update_system_state();
}

u8 Safety_IsLocked(void) {
    return (pump_locked_overwater || pump_locked_overcurr || pump_locked_overheat) ? 1u : 0u;
}

u8 Safety_GetFaultFlags(void) { return safety_fault_flags; }
u8 Safety_GetState(void) { return safety_state; }

void Safety_ManualReset(void)
{
    if(manual_reset_needed) {
        manual_reset_needed  = 0u;
        overcurr_count       = 0u;
        pump_locked_overcurr = 0u;
        safety_fault_flags  &= ~SAFETY_FAULT_OVERCURR;

        LED_Off(LED_RED_PORT, LED_RED_PIN);
        LCD_Clear();
        LCD_GoToRowCol(1u, 1u);
        LCD_SendString_Const("System Reset OK ");
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const("Monitor Active  ");
        update_system_state();
    }
}

void Safety_Run(void)
{
    Safety_CheckOvercurrent();
    tick_soil++;
    if(tick_soil >= 10u) { tick_soil = 0u; Safety_CheckSoilMoisture(); }
    tick_temp++;
    if(tick_temp >= 20u) { tick_temp = 0u; Safety_CheckTemperature(); }
}