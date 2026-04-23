#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/TIMER0/Timer0.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../../services/bit_math.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/timer0_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 6 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/timer0_interface.h"
void TMR0_Init(void);
void TMR0_Enable(void);
void TMR0_Disable(void);
void TMR0_Reset(void);
void TMR0_SetInterval_s(u8 seconds);
void TMR0_SetInterval_ms(u16 milliseconds);
void TMR0_SetCallback(void (*ptr)(void));
void TIMER0_ISR(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/timer0/../gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 18 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/TIMER0/Timer0.c"
static void (*TMR0_Callback)(void) = 0;

static u32 overflows_needed = 0;
static u8 jump_value = 0;
static u32 current_overflows = 0;


void TMR0_Init(void)
{
  ( ( (*((volatile u8*)0x81)) ) &= ~(1U << ( 5 )) ) ;
  ( ( (*((volatile u8*)0x81)) ) &= ~(1U << ( 3 )) ) ;
  ( ( (*((volatile u8*)0x81)) ) |= (1U << ( 2 )) ) ;
  ( ( (*((volatile u8*)0x81)) ) |= (1U << ( 1 )) ) ;
  ( ( (*((volatile u8*)0x81)) ) |= (1U << ( 0 )) ) ;
  ( ( (*((volatile u8*)0x0B)) ) &= ~(1U << ( 2 )) ) ;
}


void TMR0_Enable(void) {  ( ( (*((volatile u8*)0x0B)) ) |= (1U << ( 5 )) ) ; }
void TMR0_Disable(void) {  ( ( (*((volatile u8*)0x0B)) ) &= ~(1U << ( 5 )) ) ; }
void TMR0_Reset(void) {  (*((volatile u8*)0x01))  = 0; }


void TMR0_SetInterval_s(u8 seconds)
{
#line 46 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/TIMER0/Timer0.c"
 u32 total_ticks = (u32)seconds * 7812UL;
 u8 remainder = (u8)(total_ticks % 256u);
 overflows_needed = total_ticks / 256u;
 jump_value = (u8)(256u - remainder);
 current_overflows = 0;
}


void TMR0_SetInterval_ms(u16 milliseconds)
{
#line 61 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/TIMER0/Timer0.c"
 u32 total_ticks = ((u32)milliseconds * 7812UL) / 1000UL;
 u8 remainder = (u8)(total_ticks % 256u);
 overflows_needed = total_ticks / 256u;
 jump_value = (u8)(256u - remainder);
 current_overflows = 0;
}


void TMR0_SetCallback(void (*ptr)(void))
{
 if(ptr != 0)
 {
 TMR0_Callback = ptr;
 }
}


void TIMER0_ISR(void)
{
 current_overflows++;

 if(current_overflows == overflows_needed)
 {
  (*((volatile u8*)0x01))  = jump_value;
 }
 else if(current_overflows > overflows_needed)
 {
 current_overflows = 0;
 if(TMR0_Callback != 0)
 {
 TMR0_Callback();
 }
 }

  ( ( (*((volatile u8*)0x0B)) ) &= ~(1U << ( 2 )) ) ;
}
