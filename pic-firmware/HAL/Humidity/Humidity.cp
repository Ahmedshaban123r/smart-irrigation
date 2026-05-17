#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Humidity/Humidity.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/humidity_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 22 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/humidity_interface.h"
void Humidity_Init(void);
#line 31 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/humidity_interface.h"
u8 Humidity_Read(u8 *humidity, u8 *temperature);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/humidity_private.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../mcal/mcu_registers.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../mcal/../services/std_types.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../mcal/../services/delay.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../mcal/../services/std_types.h"
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../mcal/../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/public/documents/mikroelektronika/mikroc pro for pic/include/stddef.h"




typedef int ptrdiff_t;
typedef int ptrdiffram_t;
typedef long int ptrdiffrom_t;


typedef unsigned int size_t;
typedef unsigned int sizeram_t;
typedef unsigned long int sizerom_t;


typedef unsigned char wchar_t;
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/humidity_config.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../services/bit_math.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/humidity/../../services/delay.h"
#line 13 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Humidity/Humidity.c"
void Humidity_Init(void)
{

  ( ( (*((volatile u8*)0x86)) ) |= (1U << ( 0 )) ) ;
}

u8 Humidity_Read(u8 *humidity, u8 *temperature)
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
 if(++timeout > 200) return  2u ;
 }


 timeout = 0;
 while(! ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 200) return  2u ;
 }


 timeout = 0;
 while( ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 200) return  2u ;
 }


 for(i = 0; i < 5; i++)
 {
 for(j = 0; j < 8; j++)
 {

 timeout = 0;
 while(! ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 200) return  3u ;
 }
#line 79 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Humidity/Humidity.c"
 Delay_us(35);

 if( ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 dht_data[i] |= (1 << (7 - j));


 timeout = 0;
 while( ( (( (*((volatile u8*)0x06)) ) >> ( 0 )) & 1U ) )
 {
 Delay_us(2);
 if(++timeout > 200) return  3u ;
 }
 }
 }
 }


 if((u8)(dht_data[0] + dht_data[1] + dht_data[2] + dht_data[3]) != dht_data[4])
 {
 return  4u ;
 }


 *humidity = dht_data[0];
 *temperature = dht_data[2];

 return  0u ;
}
