/*
 * LCD.c
 * Irrigation Project ? HD44780 LCD Driver (4-bit mode)
 * Target: PIC16F877A | Compiler Agnostic
 */

#include "LCD_interface.h"
#include "LCD_private.h"
#include "../../SERVICES/BIT_MATH.h"

/* ????????????????????????????????????????????????????????????
   MACROS: Replaces functions to prevent 8-level Stack Overflow
   ???????????????????????????????????????????????????????????? */
#define LCD_SEND_NIBBLE(nibble) do { \
    if (GET_BIT((nibble), 4)) SET_BIT(LCD_DATA_PORT, LCD_D4_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D4_PIN); \
    if (GET_BIT((nibble), 5)) SET_BIT(LCD_DATA_PORT, LCD_D5_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D5_PIN); \
    if (GET_BIT((nibble), 6)) SET_BIT(LCD_DATA_PORT, LCD_D6_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D6_PIN); \
    if (GET_BIT((nibble), 7)) SET_BIT(LCD_DATA_PORT, LCD_D7_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D7_PIN); \
    SET_BIT(LCD_CTRL_PORT, LCD_E_PIN); \
    Generic_Delay_us(LCD_ENABLE_PULSE_US); \
    CLR_BIT(LCD_CTRL_PORT, LCD_E_PIN); \
    Generic_Delay_us(LCD_ENABLE_PULSE_US); \
} while(0)

#define LCD_SEND_BYTE(byte, rs) do { \
    if ((rs) == 1) SET_BIT(LCD_CTRL_PORT, LCD_RS_PIN); else CLR_BIT(LCD_CTRL_PORT, LCD_RS_PIN); \
    LCD_SEND_NIBBLE((byte) & 0xF0); \
    LCD_SEND_NIBBLE((u8)((byte) << 4)); \
    Generic_Delay_ms(LCD_CMD_DELAY_MS); \
} while(0)


/* ????????????????????????????????????????????????????????????
   LCD_Init() ? HD44780 4-bit power-up sequence
   ???????????????????????????????????????????????????????????? */
void LCD_Init(void)
{
    /* Set all LCD pins as output */
    CLR_BIT(LCD_CTRL_TRIS, LCD_RS_PIN);
    CLR_BIT(LCD_CTRL_TRIS, LCD_E_PIN);
    CLR_BIT(LCD_DATA_TRIS, LCD_D4_PIN);
    CLR_BIT(LCD_DATA_TRIS, LCD_D5_PIN);
    CLR_BIT(LCD_DATA_TRIS, LCD_D6_PIN);
    CLR_BIT(LCD_DATA_TRIS, LCD_D7_PIN);

    Generic_Delay_ms(LCD_INIT_DELAY_MS);

    CLR_BIT(LCD_CTRL_PORT, LCD_RS_PIN); 

    LCD_SEND_NIBBLE(0x30);   Generic_Delay_ms(5);
    LCD_SEND_NIBBLE(0x30);   Generic_Delay_ms(1);
    LCD_SEND_NIBBLE(0x30);   Generic_Delay_ms(1);

    LCD_SEND_NIBBLE(0x20);   Generic_Delay_ms(1);

    LCD_SendCommand(LCD_CMD_FUNCTION_SET_4BIT);
    LCD_SendCommand(0x08);
    LCD_SendCommand(LCD_CMD_CLEAR_DISPLAY);
    Generic_Delay_ms(LCD_CLEAR_DELAY_MS);
    LCD_SendCommand(LCD_CMD_ENTRY_MODE);
    LCD_SendCommand(LCD_CMD_DISPLAY_ON);
}

/* ????????????????????????????????????????????????????????????
   LCD Functions
   ???????????????????????????????????????????????????????????? */
void LCD_SendCommand(u8 cmd)
{
    LCD_SEND_BYTE(cmd, 0);
}

void LCD_SendChar(u8 ch)
{
    LCD_SEND_BYTE(ch, 1);
}

void LCD_SendString(char *str)
{
    u8 count = 0;
    while(*str && count < LCD_COL_MAX)
    {
        LCD_SendChar((u8)*str);
        str++; count++;
    }
}

void LCD_SendString_Const(const char *str)
{
    u8 count = 0;
    while(*str && count < LCD_COL_MAX)
    {
        LCD_SendChar((u8)*str);
        str++; count++;
    }
}

void LCD_SendNumber(s16 num)
{
    char  buf[7]; 
    u8    i   = 0;
    u8    len = 0;
    u8    neg = 0;
    char  tmp[7];

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
    if(col  < 1)  col  = 1;
    if(col  > 16) col  = 16;
    if(row != 2)  row  = 1;

    if(row == 1) address = LCD_CMD_SET_DDRAM + LCD_ROW1_OFFSET + (col - 1);
    else         address = LCD_CMD_SET_DDRAM + LCD_ROW2_OFFSET + (col - 1);
    LCD_SendCommand(address);
}

void LCD_Clear(void)
{
    LCD_SendCommand(LCD_CMD_CLEAR_DISPLAY);
    Generic_Delay_ms(LCD_CLEAR_DELAY_MS);
}
