#line 1 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/LCD/LCD.c"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 21 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_Init(void);
#line 27 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_SendCommand(u8 cmd);


void LCD_SendString_Const(const char *str);
#line 36 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_SendChar(u8 ch);
#line 43 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_SendString(char *str);
#line 49 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_SendNumber(s16 num);
#line 55 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_GoToRowCol(u8 row, u8 col);
#line 61 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_Clear(void);
#line 68 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_interface.h"
void LCD_DisplayStatus(u8 row, char *label, s16 value, char *unit);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/lcd_private.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/mcu_registers.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/../services/std_types.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/../services/delay.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/../services/std_types.h"
#line 16 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/gpio/gpio_interface.h"
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/gpio/../../services/std_types.h"
#line 31 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 1 "c:/users/abdullah/downloads/last version/irrigationproject_drivers_v5/irrigationproject/hal/lcd/../../services/bit_math.h"
#line 5 "C:/Users/Abdullah/Downloads/Last version/IrrigationProject_Drivers_v5/IrrigationProject/HAL/LCD/LCD.c"
static void LCD_SendNibble(u8 nibble)
{
 if ( ( ((nibble) >> (4)) & 1U ) )  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 4 )) ) ; else  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 4 )) ) ;
 if ( ( ((nibble) >> (5)) & 1U ) )  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 5 )) ) ; else  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 5 )) ) ;
 if ( ( ((nibble) >> (6)) & 1U ) )  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 6 )) ) ; else  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 6 )) ) ;
 if ( ( ((nibble) >> (7)) & 1U ) )  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 7 )) ) ; else  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 7 )) ) ;

  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 2 )) ) ;
 Delay_us( 10 );
  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 2 )) ) ;
 Delay_us( 10 );
}

static void LCD_SendByte(u8 byte, u8 rs)
{
 if (rs == 1)  ( ( (*((volatile u8*)0x08)) ) |= (1U << ( 0 )) ) ;
 else  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 0 )) ) ;

  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 1 )) ) ;

 LCD_SendNibble(byte & 0xF0);
 LCD_SendNibble((u8)(byte << 4));
 Delay_ms( 2 );
}

void LCD_Init(void)
{
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 0 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 1 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 2 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 4 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 5 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 6 )) ) ;
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << ( 7 )) ) ;

 Delay_ms( 20 );

  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 0 )) ) ;
  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << ( 1 )) ) ;

 LCD_SendNibble(0x30); Delay_ms(5);
 LCD_SendNibble(0x30); Delay_ms(1);
 LCD_SendNibble(0x30); Delay_ms(1);

 LCD_SendNibble(0x20); Delay_ms(1);
 LCD_SendCommand( 0x28 );
 LCD_SendCommand(0x08);
 LCD_SendCommand( 0x01 );
 Delay_ms( 2 );
 LCD_SendCommand( 0x06 );
 LCD_SendCommand( 0x0C );
}

void LCD_SendCommand(u8 cmd)
{
 LCD_SendByte(cmd, 0);
}

void LCD_SendChar(u8 ch)
{
 LCD_SendByte(ch, 1);
}

void LCD_SendString(char *str)
{
 u8 count = 0;
 while(*str && count <  16u )
 {
 LCD_SendChar((u8)*str);
 str++;
 count++;
 }
}

void LCD_SendString_Const(const char *str)
{
 u8 count = 0;
 while(*str && count <  16u )
 {
 LCD_SendChar((u8)*str);
 str++;
 count++;
 }
}

void LCD_SendNumber(s16 num)
{
 char buf[7];
 u8 i = 0;
 u8 len = 0;
 char tmp[7];

 if(num < 0)
 {
 num = -num;
 LCD_SendChar('-');
 }

 if(num == 0)
 {
 LCD_SendChar('0');
 return;
 }

 while(num > 0)
 {
 tmp[i++] = (char)('0' + (num % 10));
 num /= 10;
 }
 len = i;

 for(i = 0; i < len; i++)
 {
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
 Delay_ms( 2 );
}
