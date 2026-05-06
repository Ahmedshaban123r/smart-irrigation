/*
 * MyProject.c
 * Sensor Test — DHT11 + Soil Moisture + ACS712 Current, output on 16x2 LCD.
 * PIC16F877A @ 8 MHz | MPLAB XC8
 *
 * Wiring:
 *   DHT11 DATA  → RB0        (HUMIDITY_DATA_PIN)
 *   Soil sensor → RA0 / AN0  (ADC_CHANNEL_SOIL)
 *   ACS712      → RA2 / AN2  (ADC_CHANNEL_CURRENT)
 *   LCD         → RD1..RD7   (4-bit mode)
 *
 * Display cycles every 2 s:
 *   Page 1 — DHT11:  Row1 "Hum : XX %"   Row2 "Temp: XX C"
 *   Page 2 — Analog: Row1 "Soil: XX %"   Row2 "Curr: XXXX mA"
 */

/* MCU_Registers.h must be first: it defines _XTAL_FREQ and includes xc.h,
   which is required before #pragma config and all __delay_ms/__delay_us calls. */
#include "../MCAL/MCU_Registers.h"

/* ── XC8 Configuration Bits for PIC16F877A @ 8 MHz external crystal ── */
#pragma config FOSC  = HS       /* High-Speed crystal oscillator */
#pragma config WDTE  = OFF      /* Watchdog Timer disabled */
#pragma config PWRTE = ON       /* Power-up Timer enabled */
#pragma config BOREN = ON       /* Brown-out Reset enabled */
#pragma config LVP   = OFF      /* Low-Voltage Programming disabled */
#pragma config CPD   = OFF      /* Data EEPROM not protected */
#pragma config WRT   = OFF      /* Flash write protection off */
#pragma config CP    = OFF      /* Code protection off */

#include "../HAL/LCD/LCD_interface.h"
#include "../HAL/Humidity/Humidity_interface.h"
#include "../HAL/Soil/Soil_interface.h"
#include "../HAL/Current/Current_interface.h"
#include "../MCAL/ADC/ADC_interface.h"
#include "../SERVICES/STD_TYPES.h"

/* Definitions required by Interrupt_Manager.c externs */
volatile u8 g_tick_100ms = 0;
u8 g_frame[4]    = {0};
u8 g_frame_idx   = 0;
u8 g_frame_ready = 0;

void main(void)
{
    u8  humidity    = 0;
    u8  temperature = 0;
    u8  soil_pct    = 0;
    s16 current_mA  = 0;
    u8  dht_status  = 0;
    u8  page        = 0;

    /* VCC stabilise */
    __delay_ms(100);

    ADC_Init();
    LCD_Init();
    Humidity_Init();
    Soil_Init();
    Current_Init();

    /* Splash */
    LCD_GoToRowCol(LCD_ROW_1, 1);
    LCD_SendString_Const(" Sensor Test    ");
    LCD_GoToRowCol(LCD_ROW_2, 1);
    LCD_SendString_Const(" Initializing...");
    __delay_ms(1500);
    LCD_Clear();

    while(1)
    {
        /* Read all sensors */
        dht_status = Humidity_Read(&humidity, &temperature);
        soil_pct   = Soil_Read_Pct();
        current_mA = Current_Read_mA();

        if(page == 0)
        {
            /* Page 1: DHT11 */
            LCD_GoToRowCol(LCD_ROW_1, 1);
            if(dht_status == HUMIDITY_OK)
            {
                LCD_SendString_Const("Hum : ");
                LCD_SendNumber((s16)humidity);
                LCD_SendString_Const(" %      ");

                LCD_GoToRowCol(LCD_ROW_2, 1);
                LCD_SendString_Const("Temp: ");
                LCD_SendNumber((s16)temperature);
                LCD_SendString_Const(" C      ");
            }
            else
            {
                LCD_SendString_Const("DHT11 Error:    ");
                LCD_GoToRowCol(LCD_ROW_2, 1);
                LCD_SendString_Const("Code: ");
                LCD_SendNumber((s16)dht_status);
                LCD_SendString_Const("          ");
            }
        }
        else
        {
            /* Page 2: Soil + Current */
            LCD_GoToRowCol(LCD_ROW_1, 1);
            LCD_SendString_Const("Soil: ");
            LCD_SendNumber((s16)soil_pct);
            LCD_SendString_Const(" %      ");

            LCD_GoToRowCol(LCD_ROW_2, 1);
            LCD_SendString_Const("Curr: ");
            LCD_SendNumber(current_mA);
            LCD_SendString_Const(" mA  ");
        }

        page ^= 1u;

        __delay_ms(2000);
    }
}
