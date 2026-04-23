#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/APP/main.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/timer0/timer0_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/timer0/../../services/std_types.h"
#line 6 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/timer0/timer0_interface.h"
void TMR0_Init(void);
void TMR0_Enable(void);
void TMR0_Disable(void);
void TMR0_Reset(void);
void TMR0_SetInterval_s(u8 seconds);
void TMR0_SetInterval_ms(u16 milliseconds);
void TMR0_SetCallback(void (*ptr)(void));
void TIMER0_ISR(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/usart_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/usart_private.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/../mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/usart_config.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/../mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/../../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/../../services/bit_math.h"
#line 11 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../mcal/usart/usart_interface.h"
void UART_RX_Init(void);
void UART_TX_Init(void);


void UART_Write(u8 Data);
void UART_Write_ISR(u8 Data);
u8 UART_Read(void);


u8 UART_TX_Empty(void);

void UART_SetCallback(void (*Callback)(u8));
void UART_ISR(void);

void UART_WriteString(char *str);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/sensors_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/../services/std_types.h"
#line 19 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/sensors_interface.h"
void Sensors_Init(void);
#line 25 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/sensors_interface.h"
s16 Sensors_ReadTemperature_C(void);
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/sensors_interface.h"
s16 Sensors_ReadCurrent_mA(void);
#line 37 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/sensors_interface.h"
u8 Sensors_ReadSoilMoisture_Pct(void);
#line 44 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/sensors_interface.h"
u8 Sensors_ReadHumidity_Pct(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/../../services/std_types.h"
#line 21 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_Init(void);
#line 27 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_SendCommand(u8 cmd);


void LCD_SendString_Const(const char *str);
#line 36 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_SendChar(u8 ch);
#line 43 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_SendString(char *str);
#line 49 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_SendNumber(s16 num);
#line 55 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_GoToRowCol(u8 row, u8 col);
#line 61 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_Clear(void);
#line 68 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/lcd/lcd_interface.h"
void LCD_DisplayStatus(u8 row, char *label, s16 value, char *unit);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/relay/relay_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/relay/../../services/std_types.h"
#line 20 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/relay/relay_interface.h"
void Relay_Init(void);
#line 26 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/relay/relay_interface.h"
void Relay_On(void);
#line 32 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/relay/relay_interface.h"
void Relay_Off(void);
#line 39 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/relay/relay_interface.h"
u8 Relay_GetState(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/led/led_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/led/../../services/std_types.h"
#line 10 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/led/led_interface.h"
void LED_Init(u8 Port, u8 Pin);
void LED_On(u8 Port, u8 Pin);
void LED_Off(u8 Port, u8 Pin);
void LED_Toggle(u8 Port, u8 Pin);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/buzzer/buzzer_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/buzzer/../../services/std_types.h"
#line 22 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../hal/buzzer/buzzer_interface.h"
void Buzzer_Init(void);
void Buzzer_On(void);
void Buzzer_Off(void);
void Buzzer_Beep(u16 duration_ms);
void Buzzer_BeepN(u8 count, u16 ms_on, u16 ms_off);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../app/safety/safety_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../app/safety/../../services/std_types.h"
#line 22 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../app/safety/safety_interface.h"
void Safety_Init(void);
void Safety_CheckSoilMoisture(void);
void Safety_CheckOvercurrent(void);
void Safety_CheckTemperature(void);
u8 Safety_IsLocked(void);
u8 Safety_GetFaultFlags(void);
u8 Safety_GetState(void);
void Safety_ManualReset(void);
void Safety_Run(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/../services/bit_math.h"
#line 35 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/APP/main.c"
s16 g_temp_c;
u8 g_soil_pct;
u8 g_humidity_pct;


volatile u8 g_tick_100ms;


u8 g_frame[4];
u8 g_frame_idx;
u8 g_frame_ready;
u8 g_lcd_tick;


static void UART_SendShort_Const(const char *s)
{
 while(*s)
 {
 UART_Write(*s++);
 }
}


static void Process_Cmd(void)
{
 u8 cmd = g_frame[1];
 u8 crc = g_frame[2];

 if(crc != (u8)(g_frame[0] ^ cmd))
 {
 UART_SendShort_Const("NC\r\n");
 return;
 }

 if(cmd ==  0x01 )
 {
 if(Safety_IsLocked())
 UART_SendShort_Const("NL\r\n");
 else
 {
 Relay_On();
 UART_SendShort_Const("AP\r\n");
 }
 }
 else if(cmd ==  0x02 )
 {
 Relay_Off();
 UART_SendShort_Const("AF\r\n");
 }
 else if(cmd ==  0x03 )
 {
 Safety_ManualReset();
 UART_SendShort_Const("AR\r\n");
 }
 else
 {
 UART_SendShort_Const("NU\r\n");
 }
}


static void LCD_ShowData(void)
{

 LCD_GoToRowCol(1,1);
 LCD_SendString_Const("T:");
 LCD_SendNumber(g_temp_c);
 LCD_SendString_Const("C H:");
 if(g_humidity_pct != 0xFF)
 {
 LCD_SendNumber(g_humidity_pct);
 LCD_SendString_Const("%   ");
 }
 else
 {
 LCD_SendString_Const("--% ");
 }


 LCD_GoToRowCol(2,1);
 LCD_SendString_Const("S:");
 LCD_SendNumber(g_soil_pct);
 LCD_SendString_Const("%         ");
}


static void System_Init(void)
{
 Sensors_Init();
 LCD_Init();
 Relay_Init();
 Buzzer_Init();
 Safety_Init();

 UART_TX_Init();
 UART_RX_Init();

 TMR0_Init();
 TMR0_SetInterval_ms(100);
 TMR0_Enable();

 LCD_Clear();
 UART_SendShort_Const("RDY\r\n");
}


void main(void)
{
 System_Init();

 while(1)
 {
 if(g_tick_100ms)
 {
 g_tick_100ms = 0;

 Safety_Run();

 g_lcd_tick++;
 if(g_lcd_tick >= 5)
 {
 g_lcd_tick = 0;

 g_temp_c = Sensors_ReadTemperature_C();
 g_soil_pct = Sensors_ReadSoilMoisture_Pct();
 g_humidity_pct = Sensors_ReadHumidity_Pct();


 if(Safety_GetState() ==  0u )
 {
 LCD_ShowData();
 }

 UART_SendShort_Const("RDY\r\n");
 }
 }

 if(g_frame_ready)
 {
 g_frame_ready = 0;
 Process_Cmd();
 }
 }
}
