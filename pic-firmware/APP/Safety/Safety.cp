#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/APP/Safety/Safety.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/safety_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 22 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/safety_interface.h"
void Safety_Init(void);
void Safety_CheckSoilMoisture(void);
void Safety_CheckOvercurrent(void);
void Safety_CheckTemperature(void);
u8 Safety_IsLocked(void);
u8 Safety_GetFaultFlags(void);
u8 Safety_GetState(void);
void Safety_ManualReset(void);
void Safety_Run(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/safety_config.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/sensors_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/../services/std_types.h"
#line 19 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/sensors_interface.h"
void Sensors_Init(void);
#line 25 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/sensors_interface.h"
s16 Sensors_ReadTemperature_C(void);
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/sensors_interface.h"
s16 Sensors_ReadCurrent_mA(void);
#line 37 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/sensors_interface.h"
u8 Sensors_ReadSoilMoisture_Pct(void);
#line 44 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/sensors_interface.h"
u8 Sensors_ReadHumidity_Pct(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/relay/relay_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/relay/../../services/std_types.h"
#line 20 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/relay/relay_interface.h"
void Relay_Init(void);
#line 26 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/relay/relay_interface.h"
void Relay_On(void);
#line 32 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/relay/relay_interface.h"
void Relay_Off(void);
#line 39 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/relay/relay_interface.h"
u8 Relay_GetState(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/led/led_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/led/../../services/std_types.h"
#line 10 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/led/led_interface.h"
void LED_Init(u8 Port, u8 Pin);
void LED_On(u8 Port, u8 Pin);
void LED_Off(u8 Port, u8 Pin);
void LED_Toggle(u8 Port, u8 Pin);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/../../services/std_types.h"
#line 21 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_Init(void);
#line 27 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_SendCommand(u8 cmd);


void LCD_SendString_Const(const char *str);
#line 36 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_SendChar(u8 ch);
#line 43 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_SendString(char *str);
#line 49 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_SendNumber(s16 num);
#line 55 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_GoToRowCol(u8 row, u8 col);
#line 61 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_Clear(void);
#line 68 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/lcd/lcd_interface.h"
void LCD_DisplayStatus(u8 row, char *label, s16 value, char *unit);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/buzzer/buzzer_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/buzzer/../../services/std_types.h"
#line 22 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../hal/buzzer/buzzer_interface.h"
void Buzzer_Init(void);
void Buzzer_On(void);
void Buzzer_Off(void);
void Buzzer_Beep(u16 duration_ms);
void Buzzer_BeepN(u8 count, u16 ms_on, u16 ms_off);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../mcal/gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/app/safety/../../services/std_types.h"
#line 21 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/APP/Safety/Safety.c"
static u8 safety_state =  0u ;
static u8 safety_fault_flags =  0x00u ;
static u8 overcurr_count = 0u;
static u8 manual_reset_needed = 0u;

static u8 pump_locked_overwater = 0u;
static u8 pump_locked_overcurr = 0u;
static u8 pump_locked_overheat = 0u;

static u16 tick_soil = 0u;
static u16 tick_temp = 0u;

static u8 lcd_last_soil = 0u;
static u8 lcd_last_current = 0u;
static u8 lcd_last_temp = 0u;

static void update_system_state(void)
{
 if(safety_fault_flags !=  0x00u )
 {
 safety_state =  2u ;
 }
 else if(pump_locked_overwater || pump_locked_overcurr || pump_locked_overheat)
 {
 safety_state =  1u ;
 }
 else
 {
 safety_state =  0u ;
 }
}

static void emergency_shutdown_all(void)
{
 Relay_Off();
 LED_Off( (*((volatile u8*)0x06)) ,  6 );
 LED_On( (*((volatile u8*)0x06)) ,  7 );
 Buzzer_BeepN(3u, 500u, 200u);
}

void Safety_Init(void)
{
 safety_state =  0u ;
 safety_fault_flags =  0x00u ;
 overcurr_count = 0u;
 manual_reset_needed = 0u;
 pump_locked_overwater = 0u;
 pump_locked_overcurr = 0u;
 pump_locked_overheat = 0u;
 tick_soil = 0u;
 tick_temp = 0u;

 lcd_last_soil = 0u;
 lcd_last_current = 0u;
 lcd_last_temp = 0u;

 LED_Init( (*((volatile u8*)0x86)) ,  6 );
 LED_Init( (*((volatile u8*)0x86)) ,  7 );
 LED_Off( (*((volatile u8*)0x06)) ,  6 );
 LED_Off( (*((volatile u8*)0x06)) ,  7 );
}

void Safety_CheckSoilMoisture(void)
{
 u8 soil_pct = Sensors_ReadSoilMoisture_Pct();
 u8 new_state = 0u;

 if(soil_pct >  95u ) new_state = 2u;
 else if(soil_pct >  80u ) new_state = 1u;
 else new_state = 0u;

 if(new_state == 2u)
 {
 if(!manual_reset_needed)
 {
 Relay_Off();
 pump_locked_overwater = 1u;
 safety_fault_flags |=  0x01u ;
 }
 LED_Off( (*((volatile u8*)0x06)) ,  6 );
 LED_On( (*((volatile u8*)0x06)) ,  7 );

 if(lcd_last_soil != 2u)
 {
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
 else if(soil_pct <=  65u  && (safety_fault_flags &  0x01u ))
 {
 safety_fault_flags &= ~ 0x01u ;
 pump_locked_overwater = 0u;
 new_state = 0u;

 LED_Off( (*((volatile u8*)0x06)) ,  7 );
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
 LED_On( (*((volatile u8*)0x06)) ,  6 );
 if(lcd_last_soil != 1u)
 {
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
 if(!(safety_fault_flags &  0x01u ))
 {
 pump_locked_overwater = 0u;
 LED_Off( (*((volatile u8*)0x06)) ,  6 );
 }
 }

 lcd_last_soil = new_state;
 update_system_state();
}

void Safety_CheckOvercurrent(void)
{
 s16 current_ma = Sensors_ReadCurrent_mA();
 u16 abs_ma = (current_ma < 0) ? (u16)(-current_ma) : (u16)current_ma;
 u8 new_state = 0u;

 if(abs_ma >  750u )
 {
 new_state = 2u;
 if(!manual_reset_needed)
 {
 emergency_shutdown_all();
 pump_locked_overcurr = 1u;
 safety_fault_flags |=  0x02u ;
 manual_reset_needed = 1u;
 overcurr_count = 0u;
 }

 if(lcd_last_current != 2u)
 {
 LCD_Clear();
 LCD_GoToRowCol(1u, 1u);
 LCD_SendString_Const("! OVERCURR FAULT");
 }
 LCD_GoToRowCol(2u, 1u);
 LCD_SendString_Const("I:");
 LCD_SendNumber((s16)abs_ma);
 LCD_SendString_Const("mA LOCKED  ");
 }
 else if(abs_ma >  600u )
 {
 new_state = 1u;
 overcurr_count++;

 if(overcurr_count >=  5u )
 {
 LED_On( (*((volatile u8*)0x06)) ,  6 );
 if(lcd_last_current != 1u)
 {
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
 new_state = 0u;
 overcurr_count = 0u;
 if(!(safety_fault_flags &  0x02u ))
 {
 pump_locked_overcurr = 0u;
 LED_Off( (*((volatile u8*)0x06)) ,  6 );
 }
 }

 lcd_last_current = new_state;
 update_system_state();
}

void Safety_CheckTemperature(void)
{
 s16 temp_c = Sensors_ReadTemperature_C();
 u8 new_state = 0u;

 if(temp_c >  55 ) new_state = 2u;
 else if(temp_c >  45 ) new_state = 1u;
 else new_state = 0u;

 if(new_state == 2u)
 {
 if(!manual_reset_needed)
 {
 emergency_shutdown_all();
 pump_locked_overheat = 1u;
 safety_fault_flags |=  0x04u ;
 }

 if(lcd_last_temp != 2u)
 {
 LCD_Clear();
 LCD_GoToRowCol(1u, 1u);
 LCD_SendString_Const("! OVERHEAT FAULT");
 }
 LCD_GoToRowCol(2u, 1u);
 LCD_SendString_Const("T:");
 LCD_SendNumber((s16)temp_c);
 LCD_SendString_Const("C SHUTDOWN  ");
 }
 else if(temp_c <=  40  && (safety_fault_flags &  0x04u ))
 {
 safety_fault_flags &= ~ 0x04u ;
 pump_locked_overheat = 0u;
 new_state = 0u;

 LED_Off( (*((volatile u8*)0x06)) ,  7 );
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
 LED_On( (*((volatile u8*)0x06)) ,  6 );
 if(lcd_last_temp != 1u)
 {
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
 if(!(safety_fault_flags &  0x04u ))
 {
 pump_locked_overheat = 0u;
 LED_Off( (*((volatile u8*)0x06)) ,  6 );
 }
 }

 lcd_last_temp = new_state;
 update_system_state();
}

u8 Safety_IsLocked(void)
{
 return (pump_locked_overwater || pump_locked_overcurr || pump_locked_overheat) ? 1u : 0u;
}

u8 Safety_GetFaultFlags(void) { return safety_fault_flags; }
u8 Safety_GetState(void) { return safety_state; }

void Safety_ManualReset(void)
{
 if(manual_reset_needed)
 {
 manual_reset_needed = 0u;
 overcurr_count = 0u;
 pump_locked_overcurr = 0u;
 safety_fault_flags &= ~ 0x02u ;

 LED_Off( (*((volatile u8*)0x06)) ,  7 );

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
