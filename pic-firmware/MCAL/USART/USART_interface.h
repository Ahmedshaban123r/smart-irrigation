#ifndef USART_INTERFACE_H
#define USART_INTERFACE_H

#include "USART_private.h"
#include "USART_config.h"
#include "../MCU_Registers.h"
#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

/* Initialization */
void UART_RX_Init(void);
void UART_TX_Init(void);

/* Data Operations */
void UART_Write(u8 Data);
void UART_Write_ISR(u8 Data);
u8 UART_Read(void);

/* Status */
u8 UART_TX_Empty(void);

void UART_SetCallback(void (*Callback)(u8));
void UART_ISR(void);

void UART_WriteString(char *str);

#endif