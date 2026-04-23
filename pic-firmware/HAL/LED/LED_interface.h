#ifndef LED_INTERFACE_H
#define LED_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

/* LED States */
#define LED_OFF    0
#define LED_ON     1
/* Yellow LED on RB6 for Test Bench */
#define LED_YELLOW_PORT    0x06   // PORTB Address
#define LED_YELLOW_TRIS    0x86   // TRISB Address
#define LED_YELLOW_PIN     6      // Pin 6 (RB6)

void LED_Init(u8 Port, u8 Pin);
void LED_On(u8 Port, u8 Pin);
void LED_Off(u8 Port, u8 Pin);
void LED_Toggle(u8 Port, u8 Pin);

#endif