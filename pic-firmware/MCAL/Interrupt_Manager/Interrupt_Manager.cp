#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/Interrupt_Manager/Interrupt_Manager.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/interrupt_manager_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../../services/bit_math.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/interrupt_manager_private.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/interrupt_manager_config.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/../gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/interrupt_manager/interrupt_manager_interface.h"
extern void TIMER0_ISR(void);
extern void UART_ISR(void);
#line 12 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/Interrupt_Manager/Interrupt_Manager.c"
extern volatile u8 g_tick_100ms;
extern u8 g_frame[4];
extern u8 g_frame_idx;
extern u8 g_frame_ready;
#line 21 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/Interrupt_Manager/Interrupt_Manager.c"
 void interrupt() 
{

 if ( ( (( (*((volatile u8*)0x0B)) ) >> ( 2 )) & 1U ) ) {

  ( ( (*((volatile u8*)0x0B)) ) &= ~(1U << ( 2 )) ) ;
 g_tick_100ms = 1;
 }


 if ( ( (( (*((volatile u8*)0x0C)) ) >> ( 5 )) & 1U ) ) {
 u8 b =  (*((volatile u8*)0x1A)) ;


 if(g_frame_idx == 0u) {
 if(b ==  0xCC ) {
 g_frame[0] = b;
 g_frame_idx = 1u;
 }
 }
 else if(g_frame_idx < 3u) {
 g_frame[g_frame_idx++] = b;
 }
 else {
 g_frame[3] = b;
 g_frame_idx = 0u;
 if(b ==  0xDD ) {
 g_frame_ready = 1u;
 }
 }
 }
}
