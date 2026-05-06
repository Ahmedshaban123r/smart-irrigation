#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Relay/Relay.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/relay_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 20 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/relay_interface.h"
void Relay_Init(void);
#line 26 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/relay_interface.h"
void Relay_On(void);
#line 32 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/relay_interface.h"
void Relay_Off(void);
#line 39 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/relay_interface.h"
u8 Relay_GetState(void);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/relay_private.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/gpio/gpio_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/gpio/../../services/std_types.h"
#line 31 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/mcu_registers.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/../services/std_types.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/../services/delay.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/../services/std_types.h"
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../mcal/../services/delay.h"
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
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/relay/../../services/bit_math.h"
#line 5 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Relay/Relay.c"
void Relay_Init(void)
{
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 0 )) ) ;
  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 0 )) ) ;
}

void Relay_On(void)
{
  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 0 )) ) ;
}

void Relay_Off(void)
{
  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 0 )) ) ;
}

u8 Relay_GetState(void)
{
 return (u8) ( (( (*((volatile u8*)0x08)) ) >> ( 0 )) & 1U ) ;
}
