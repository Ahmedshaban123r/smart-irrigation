#if defined(__XC)
    #pragma config FOSC = HS
    #pragma config WDTE = OFF
    #pragma config PWRTE = OFF
    #pragma config BOREN = OFF
    #pragma config LVP = OFF
    #pragma config CPD = OFF
    #pragma config WRT = OFF
    #pragma config CP = OFF
#endif

#include "../MCAL/MCU_Registers.h"
#include "../MCAL/TIMER0/Timer0_interface.h"
#include "../MCAL/USART/USART_interface.h"
#include "../HAL/Current/Current_interface.h"
#include "../HAL/Humidity/Humidity_interface.h"
#include "../HAL/Soil/Soil_interface.h"
#include "../HAL/Temperature/Temp_interface.h"
#include "../HAL/LCD/LCD_interface.h"
#include "../HAL/Relay/Relay_interface.h"
#include "../HAL/LED/LED_interface.h"
#include "../HAL/Buzzer/Buzzer_interface.h"
#include "../APP/Safety/Safety_interface.h"
#include "../MCAL/ADC/ADC_interface.h"
#include "../SERVICES/STD_TYPES.h"
#include "../SERVICES/BIT_MATH.h"

/* UART Constants */
#define UART_START_APP   0xCC
#define UART_END_APP     0xDD
#define CMD_PUMP_ON      0x01
#define CMD_PUMP_OFF     0x02
#define CMD_MANUAL_RESET 0x03

/* Shared Data */
s16 g_temp_c;
u8  g_soil_pct;
u8  g_humidity_pct;

/* Flags */
volatile u8 g_tick_100ms;

/* UART Frame */
u8 g_frame[4];
u8 g_frame_idx;
u8 g_frame_ready;
u8 g_lcd_tick;

static void UART_SendShort_Const(const char *s) {
    while(*s) { UART_Write(*s++); }
}

static void Process_Cmd(void) {
    u8 cmd = g_frame[1];
    u8 crc = g_frame[2];

    if(crc != (u8)(g_frame[0] ^ cmd)) {
        UART_SendShort_Const("NC\r\n");
        return;
    }

    if(cmd == CMD_PUMP_ON) {
        if(Safety_IsLocked()) UART_SendShort_Const("NL\r\n");
        else { Relay_On(); UART_SendShort_Const("AP\r\n"); }
    }
    else if(cmd == CMD_PUMP_OFF) {
        Relay_Off(); UART_SendShort_Const("AF\r\n");
    }
    else if(cmd == CMD_MANUAL_RESET) {
        Safety_ManualReset(); UART_SendShort_Const("AR\r\n");
    }
    else { UART_SendShort_Const("NU\r\n"); }
}

static void LCD_ShowData(void) {
    /* Padded string with extra spaces to clear any leftover characters */
    LCD_GoToRowCol(1,1);
    LCD_SendString_Const("T:");
    LCD_SendNumber(g_temp_c);
    LCD_SendString_Const("C H:");
    if(g_humidity_pct != 0xFF) {
        LCD_SendNumber(g_humidity_pct);
        LCD_SendString_Const("%     "); 
    } else {
        LCD_SendString_Const("--%   "); 
    }

    LCD_GoToRowCol(2,1);
    LCD_SendString_Const("S:");
    LCD_SendNumber(g_soil_pct);
    LCD_SendString_Const("%         ");
}

static void System_Init(void) {
    ADC_Init();
    Current_Init();
    Soil_Init();
    Temp_Init();
    Humidity_Init();
    LCD_Init();
    Relay_Init();
    Buzzer_Init();
    Safety_Init();

    /* UART restored safely since Relay is on RD0 */
    UART_TX_Init();
    UART_RX_Init();

    TMR0_Init();
    TMR0_SetInterval_ms(100);
    TMR0_Enable();
    LCD_Clear();
    UART_SendShort_Const("RDY\r\n");
}

void main(void) {
    System_Init();
    
    while(1) {
        if(g_tick_100ms) {
            g_tick_100ms = 0;
            Safety_Run();

            /* ========================================================
               TESTBENCH HACKS (To simulate without ESP8266 App)
               ======================================================== */
            /* 1. Hardware Reset: Drop Temp < 10C to trigger manual reset */
            if(Temp_Read_C() < 10) { Safety_ManualReset(); }

            /* 2. Auto-Pump: Force the motor ON if system is safe */
            if(!Safety_IsLocked()) { Relay_On(); }
            /* ======================================================== */

            g_lcd_tick++;
            if(g_lcd_tick >= 5) {
                g_lcd_tick = 0;
                g_temp_c       = Temp_Read_C();
                g_soil_pct     = Soil_Read_Pct();
                g_humidity_pct = Humidity_Read();

                if(Safety_GetState() == SAFETY_STATE_NORMAL) {
                    LCD_ShowData();
                }
                UART_SendShort_Const("RDY\r\n");
            }
        }
        if(g_frame_ready) {
            g_frame_ready = 0;
            Process_Cmd();
        }
    }
}