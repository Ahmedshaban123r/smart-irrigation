#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/usart_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/usart_private.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../mcu_registers.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../../services/delay.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../../services/std_types.h"
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../../services/delay.h"
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
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/usart_config.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../mcu_registers.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../../services/std_types.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/../../services/bit_math.h"
#line 11 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/usart/usart_interface.h"
void UART_RX_Init(void);
void UART_TX_Init(void);


void UART_Write(u8 Data);
void UART_Write_ISR(u8 Data);
u8 UART_Read(void);


u8 UART_TX_Empty(void);

void UART_SetCallback(void (*Callback)(u8));
void UART_ISR(void);

void UART_WriteString(char *str);
#line 8 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
static void (*UART_Callback)(u8) = 0;
#line 14 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
void UART_RX_Init(void)
{

  ( ( (*((volatile u8*)0x98)) ) |= (1U << ( 2 )) ) ;

  (*((volatile u8*)0x99))  = 51;

  ( ( (*((volatile u8*)0x98)) ) &= ~(1U << ( 4 )) ) ;

  ( ( (*((volatile u8*)0x18)) ) |= (1U << ( 7 )) ) ;

  ( ( (*((volatile u8*)0x18)) ) |= (1U << ( 4 )) ) ;

  ( ( (*((volatile u8*)0x8C)) ) |= (1U << ( 5 )) ) ;

  ( ( (*((volatile u8*)0x0B)) ) |= (1U << ( 6 )) ) ;
  ( ( (*((volatile u8*)0x0B)) ) |= (1U << ( 7 )) ) ;
}
#line 37 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
void UART_TX_Init(void)
{

  ( ( (*((volatile u8*)0x98)) ) |= (1U << ( 2 )) ) ;

  (*((volatile u8*)0x99))  = 51;

  ( ( (*((volatile u8*)0x98)) ) &= ~(1U << ( 4 )) ) ;

  ( ( (*((volatile u8*)0x18)) ) |= (1U << ( 7 )) ) ;

  ( ( (*((volatile u8*)0x98)) ) |= (1U << ( 5 )) ) ;
}
#line 55 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
void UART_Write(u8 Data)
{

 while(! ( (( (*((volatile u8*)0x98)) ) >> ( 1 )) & 1U ) );

  (*((volatile u8*)0x19))  = Data;
}

void UART_Write_ISR(u8 Data) {
 while(! ( (( (*((volatile u8*)0x98)) ) >> ( 1 )) & 1U ) );

  (*((volatile u8*)0x19))  = Data;
}
#line 73 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
u8 UART_Read(void)
{

 while(! ( (( (*((volatile u8*)0x0C)) ) >> ( 5 )) & 1U ) );

 return  (*((volatile u8*)0x1A)) ;
}
#line 85 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
u8 UART_TX_Empty(void)
{

 return  ( (( (*((volatile u8*)0x98)) ) >> ( 1 )) & 1U ) ;
}
#line 95 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/USART/USART.c"
void UART_SetCallback(void (*Callback)(u8))
{

 if(Callback != 0)
 {
 UART_Callback = Callback;
 }

}

void UART_ISR(void)
{

 u8 UART_data =  (*((volatile u8*)0x1A)) ;
 if(UART_Callback != 0)
 {
 UART_Callback(UART_data);
 }

}

void UART_WriteString(char *str)
{
 while(*str)
 {
 UART_Write(*str++);
 }
}
