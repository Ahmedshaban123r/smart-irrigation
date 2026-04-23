#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/Buzzer/Buzzer.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/buzzer_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 22 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/buzzer_interface.h"
void Buzzer_Init(void);
void Buzzer_On(void);
void Buzzer_Off(void);
void Buzzer_Beep(u16 duration_ms);
void Buzzer_BeepN(u8 count, u16 ms_on, u16 ms_off);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/buzzer_private.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../mcal/mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../services/bit_math.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/buzzer/../../services/std_types.h"
#line 15 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/Buzzer/Buzzer.c"
void Buzzer_Init(void)
{
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 1 )) ) ;
  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 1 )) ) ;
}

void Buzzer_On(void)
{
  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 1 )) ) ;
}

void Buzzer_Off(void)
{
  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 1 )) ) ;
}

void Buzzer_Beep(u16 duration_ms)
{
 Buzzer_On();
 Generic_Delay_ms(duration_ms);
 Buzzer_Off();
}

void Buzzer_BeepN(u8 count, u16 ms_on, u16 ms_off)
{
 u8 i = 0u;
 for(i = 0u; i < count; i++)
 {
 Buzzer_On();
 Generic_Delay_ms(ms_on);
 Buzzer_Off();

 if(i < (u8)(count - 1u))
 {
 Generic_Delay_ms(ms_off);
 }
 }
}
