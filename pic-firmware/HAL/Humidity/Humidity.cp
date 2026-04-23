#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/Humidity/Humidity.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/humidity_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 19 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/humidity_interface.h"
void Humidity_Init(void);
#line 27 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/humidity_interface.h"
u8 Humidity_Read(u8 *humidity, s8 *temperature);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/humidity_private.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/humidity_config.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/humidity/../../services/bit_math.h"
#line 12 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/Humidity/Humidity.c"
void Humidity_Init(void)
{

  ( ( (*((volatile u8*)0x86)) ) |= (1U << ( 0 )) ) ;
}

u8 Humidity_Read(u8 *humidity, s8 *temperature)
{

 u8 dht_data[5] = {0, 0, 0, 0, 0};
 u8 i = 0, j = 0;
 u16 timeout = 0;


  ( ( (*((volatile u8*)0x86)) ) &= ~(1U << ( 0 )) ) ;
  ( ( (*((volatile u8*)0x06)) ) &= ~(1U << ( 0 )) ) ;
 Delay_ms(18);

  ( ( (*((volatile u8*)0x06)) ) |= (1U << ( 0 )) ) ;
 Delay_us(30);

  ( ( (*((volatile u8*)0x86)) ) |= (1U << ( 0 )) ) ;



 timeout = 0;
 while( ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 50) return  1u ;
 }


 timeout = 0;
 while(! ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 50) return  1u ;
 }


 timeout = 0;
 while( ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 50) return  1u ;
 }


 for(i = 0; i < 5; i++)
 {
 for(j = 0; j < 8; j++)
 {

 timeout = 0;
 while(! ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 50) return  1u ;
 }
#line 78 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/Humidity/Humidity.c"
 Delay_us(35);

 if( ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 dht_data[i] |= (1 << (7 - j));


 timeout = 0;
 while( ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 50) return  1u ;
 }
 }
 }
 }


 if((u8)(dht_data[0] + dht_data[1] + dht_data[2] + dht_data[3]) != dht_data[4])
 {
 return  1u ;
 }



 *humidity = dht_data[0];
 *temperature = dht_data[2];
#line 111 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/Humidity/Humidity.c"
 return  0u ;
}
