#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/LCD/LCD.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 21 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_Init(void);
#line 27 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_SendCommand(u8 cmd);


void LCD_SendString_Const(const char *str);
#line 36 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_SendChar(u8 ch);
#line 43 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_SendString(char *str);
#line 49 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_SendNumber(s16 num);
#line 55 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_GoToRowCol(u8 row, u8 col);
#line 61 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_Clear(void);
#line 68 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_interface.h"
void LCD_DisplayStatus(u8 row, char *label, s16 value, char *unit);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/lcd_private.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/../../mcal/mcu_registers.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/../../mcal/../services/std_types.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/../../mcal/../services/delay.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/../../mcal/../services/std_types.h"
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/../../mcal/../services/delay.h"
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
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/lcd/../../services/bit_math.h"
#line 36 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/LCD/LCD.c"
void LCD_Init(void)
{

  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 2 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 3 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 4 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 5 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 6 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 7 )) ) ;

 Generic_Delay_ms( 20 );

  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 2 )) ) ;

  do { if ( ( (((0x30)) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( (((0x30)) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( (((0x30)) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( (((0x30)) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; Generic_Delay_ms(5);
  do { if ( ( (((0x30)) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( (((0x30)) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( (((0x30)) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( (((0x30)) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; Generic_Delay_ms(1);
  do { if ( ( (((0x30)) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( (((0x30)) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( (((0x30)) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( (((0x30)) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; Generic_Delay_ms(1);

  do { if ( ( (((0x20)) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( (((0x20)) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( (((0x20)) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( (((0x20)) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; Generic_Delay_ms(1);

 LCD_SendCommand( 0x28 );
 LCD_SendCommand(0x08);
 LCD_SendCommand( 0x01 );
 Generic_Delay_ms( 2 );
 LCD_SendCommand( 0x06 );
 LCD_SendCommand( 0x0C );
}
#line 67 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/LCD/LCD.c"
void LCD_SendCommand(u8 cmd)
{
  do { if ((0) == 1) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 2 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 2 )) ) ; do { if ( ( ((((cmd) & 0xF0)) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( ((((cmd) & 0xF0)) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( ((((cmd) & 0xF0)) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( ((((cmd) & 0xF0)) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; do { if ( ( ((((u8)((cmd) << 4))) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( ((((u8)((cmd) << 4))) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( ((((u8)((cmd) << 4))) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( ((((u8)((cmd) << 4))) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; Generic_Delay_ms( 2 ); } while(0) ;
}

void LCD_SendChar(u8 ch)
{
  do { if ((1) == 1) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 2 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 2 )) ) ; do { if ( ( ((((ch) & 0xF0)) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( ((((ch) & 0xF0)) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( ((((ch) & 0xF0)) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( ((((ch) & 0xF0)) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; do { if ( ( ((((u8)((ch) << 4))) >> (4)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ; if ( ( ((((u8)((ch) << 4))) >> (5)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ; if ( ( ((((u8)((ch) << 4))) >> (6)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ; if ( ( ((((u8)((ch) << 4))) >> (7)) & 1U ) ) ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ; ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 3 )) ) ; Generic_Delay_us( 10 ); ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 3 )) ) ; Generic_Delay_us( 10 ); } while(0) ; Generic_Delay_ms( 2 ); } while(0) ;
}

void LCD_SendString(char *str)
{
 u8 count = 0;
 while(*str && count <  16u )
 {
 LCD_SendChar((u8)*str);
 str++; count++;
 }
}

void LCD_SendString_Const(const char *str)
{
 u8 count = 0;
 while(*str && count <  16u )
 {
 LCD_SendChar((u8)*str);
 str++; count++;
 }
}

void LCD_SendNumber(s16 num)
{
 char buf[7];
 u8 i = 0;
 u8 len = 0;
 u8 neg = 0;
 char tmp[7];

 if(num < 0) {
 neg = 1;
 num = -num;
 LCD_SendChar('-');
 }
 if(num == 0) {
 LCD_SendChar('0');
 return;
 }
 while(num > 0) {
 tmp[i++] = (char)('0' + (num % 10));
 num /= 10;
 }
 len = i;
 for(i = 0; i < len; i++) {
 buf[i] = tmp[len - 1 - i];
 }
 buf[len] = '\0';
 LCD_SendString(buf);
}

void LCD_GoToRowCol(u8 row, u8 col)
{
 u8 address = 0;
 if(col < 1) col = 1;
 if(col > 16) col = 16;
 if(row != 2) row = 1;

 if(row == 1) address =  0x80  +  0x00  + (col - 1);
 else address =  0x80  +  0x40  + (col - 1);
 LCD_SendCommand(address);
}

void LCD_Clear(void)
{
 LCD_SendCommand( 0x01 );
 Generic_Delay_ms( 2 );
}
