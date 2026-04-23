#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/ADC/ADC.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/adc_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 23 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/adc_interface.h"
void ADC_Init(void);
#line 32 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/adc_interface.h"
u16 ADC_Read(u8 channel);
#line 40 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/adc_interface.h"
u16 ADC_ReadAverage(u8 channel, u8 samples);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/adc_private.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/adc_config.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../../services/bit_math.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/mcal/adc/../../services/std_types.h"
#line 16 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/MCAL/ADC/ADC.c"
void ADC_Init(void)
{

  ( ( (*((volatile u8*)0x85)) ) |= (1U << ( 0 )) ) ;
  ( ( (*((volatile u8*)0x85)) ) |= (1U << ( 1 )) ) ;
  ( ( (*((volatile u8*)0x85)) ) |= (1U << ( 2 )) ) ;


  (*((volatile u8*)0x9F))  =  0b10000000 ;


  (*((volatile u8*)0x1F))  &= 0b00111111;
  (*((volatile u8*)0x1F))  |= ( 0b10  << 6);
  ( ( (*((volatile u8*)0x1F)) ) |= (1U << ( 0 )) ) ;


 Generic_Delay_us( 25 );
}

u16 ADC_Read(u8 channel)
{
 u16 result = 0;


  (*((volatile u8*)0x1F))  &= 0b11000111;
  (*((volatile u8*)0x1F))  |= (u8)((channel & 0x07) << 3);


 Generic_Delay_us( 25 );


  ( ( (*((volatile u8*)0x1F)) ) |= (1U << ( 2 )) ) ;


 while( ( (( (*((volatile u8*)0x1F)) ) >> ( 2 )) & 1U ) );


 result = (u16) (*((volatile u8*)0x1E))  << 8;
 result |= (u16) (*((volatile u8*)0x9E)) ;
 result &= 0x03FF;

 return result;
}

u16 ADC_ReadAverage(u8 channel, u8 samples)
{
 u32 sum = 0;
 u8 i = 0;

 if(samples == 0) return 0;

 for(i = 0; i < samples; i++)
 {
 sum += ADC_Read(channel);
 }
 return (u16)(sum / samples);
}
