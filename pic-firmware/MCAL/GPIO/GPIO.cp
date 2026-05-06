#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/GPIO/GPIO.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/gpio_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 31 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/gpio_private.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/../mcu_registers.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/../../services/std_types.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/../../services/delay.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/../../services/std_types.h"
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/../../services/delay.h"
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
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/gpio_config.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/gpio/../../services/bit_math.h"
#line 9 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/GPIO/GPIO.c"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction)
{
 switch(Port)
 {
 case  0 :
 if(Direction ==  0 )  ( ( (*((volatile u8*)0x85)) ) &= ~(1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x85)) ) |= (1U << (Pin)) ) ;
 break;
 case  1 :
 if(Direction ==  0 )  ( ( (*((volatile u8*)0x86)) ) &= ~(1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x86)) ) |= (1U << (Pin)) ) ;
 break;
 case  2 :
 if(Direction ==  0 )  ( ( (*((volatile u8*)0x87)) ) &= ~(1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x87)) ) |= (1U << (Pin)) ) ;
 break;
 case  3 :
 if(Direction ==  0 )  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x88)) ) |= (1U << (Pin)) ) ;
 break;
 case  4 :
 if(Direction ==  0 )  ( ( (*((volatile u8*)0x89)) ) &= ~(1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x89)) ) |= (1U << (Pin)) ) ;
 break;
 default: break;
 }
}

void SetPinValue(u8 Port, u8 Pin, u8 Value)
{
 switch(Port)
 {
 case  0 :
 if(Value ==  1 )  ( ( (*((volatile u8*)0x05)) ) |= (1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x05)) ) &= ~(1U << (Pin)) ) ;
 break;
 case  1 :
 if(Value ==  1 )  ( ( (*((volatile u8*)0x06)) ) |= (1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x06)) ) &= ~(1U << (Pin)) ) ;
 break;
 case  2 :
 if(Value ==  1 )  ( ( (*((volatile u8*)0x07)) ) |= (1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x07)) ) &= ~(1U << (Pin)) ) ;
 break;
 case  3 :
 if(Value ==  1 )  ( ( (*((volatile u8*)0x08)) ) |= (1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << (Pin)) ) ;
 break;
 case  4 :
 if(Value ==  1 )  ( ( (*((volatile u8*)0x09)) ) |= (1U << (Pin)) ) ;
 else  ( ( (*((volatile u8*)0x09)) ) &= ~(1U << (Pin)) ) ;
 break;
 default: break;
 }
}

u8 GetPinValue(u8 Port, u8 Pin)
{
 u8 val = 0;
 switch(Port)
 {
 case  0 : val =  ( (( (*((volatile u8*)0x05)) ) >> (Pin)) & 1U ) ; break;
 case  1 : val =  ( (( (*((volatile u8*)0x06)) ) >> (Pin)) & 1U ) ; break;
 case  2 : val =  ( (( (*((volatile u8*)0x07)) ) >> (Pin)) & 1U ) ; break;
 case  3 : val =  ( (( (*((volatile u8*)0x08)) ) >> (Pin)) & 1U ) ; break;
 case  4 : val =  ( (( (*((volatile u8*)0x09)) ) >> (Pin)) & 1U ) ; break;
 default: break;
 }
 return val;
}

void SetPortDirection(u8 Port, u8 Direction)
{
 switch(Port)
 {
 case  0 :  (*((volatile u8*)0x85))  = Direction; break;
 case  1 :  (*((volatile u8*)0x86))  = Direction; break;
 case  2 :  (*((volatile u8*)0x87))  = Direction; break;
 case  3 :  (*((volatile u8*)0x88))  = Direction; break;
 case  4 :  (*((volatile u8*)0x89))  = Direction; break;
 default: break;
 }
}

void SetPortValue(u8 Port, u8 Value)
{
 switch(Port)
 {
 case  0 :  (*((volatile u8*)0x05))  = Value; break;
 case  1 :  (*((volatile u8*)0x06))  = Value; break;
 case  2 :  (*((volatile u8*)0x07))  = Value; break;
 case  3 :  (*((volatile u8*)0x08))  = Value; break;
 case  4 :  (*((volatile u8*)0x09))  = Value; break;
 default: break;
 }
}

u8 GetPortValue(u8 Port)
{
 switch(Port)
 {
 case  0 : return  (*((volatile u8*)0x05)) ;
 case  1 : return  (*((volatile u8*)0x06)) ;
 case  2 : return  (*((volatile u8*)0x07)) ;
 case  3 : return  (*((volatile u8*)0x08)) ;
 case  4 : return  (*((volatile u8*)0x09)) ;
 default: return 0;
 }
}

void GPIO_Init(void)
{
  (*((volatile u8*)0x85))  =  0xFF ;
  (*((volatile u8*)0x86))  =  0b00111110 ;
  (*((volatile u8*)0x87))  =  0b10000000 ;
  (*((volatile u8*)0x88))  =  0x00 ;
  (*((volatile u8*)0x89))  =  0xFF ;

  (*((volatile u8*)0x05))  =  0x00 ;
  (*((volatile u8*)0x06))  =  0x00 ;
  (*((volatile u8*)0x07))  =  0x00 ;
  (*((volatile u8*)0x08))  =  0x00 ;
  (*((volatile u8*)0x09))  =  0x00 ;
}
