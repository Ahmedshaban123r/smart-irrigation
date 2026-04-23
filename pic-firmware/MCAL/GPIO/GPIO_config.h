/*
 * GPIO_config.h
 * Irrigation Project — Pin Direction & Initial Value Config
 *
 * PORTA:  RA0=Soil(IN), RA1=Temp/LM35(IN), RA2=Current/ACS712(IN)  → all analog inputs
 * PORTB:  RB0=Ultrasonic_TRIG(OUT), RB1=Ultrasonic_ECHO(IN)
 *         RB6=LED_YELLOW(OUT), RB7=LED_RED(OUT)
 * PORTC:  RC6=UART_TX(OUT), RC7=UART_RX(IN)
 * PORTD:  RD0=RELAY(OUT), RD1=BUZZER(OUT)
 *         RD2=LCD_RS(OUT), RD3=LCD_RW(OUT), RD4=LCD_E(OUT)
 *         RD4..RD7 = LCD data nibble (OUT)
 * PORTE:  not used
 *
 * Note: TRISA is overridden by ADC_Init() to set analog pins as input.
 *       Values here serve as the baseline before ADC init.
 */

#ifndef GPIO_CONFIG_H
#define GPIO_CONFIG_H

/*
 * Direction: 0 = OUTPUT, 1 = INPUT
 * PORTA: all analog inputs (ADC driver will set TRISA = 0xFF)
 */
#define GPIO_PORTA_DIR       0xFF   /* All inputs (analog) */

/*
 * PORTB:
 *   Bit0 = Trig  → OUTPUT (0)
 *   Bit1 = Echo  → INPUT  (1)
 *   Bit6 = LED_Y → OUTPUT (0)
 *   Bit7 = LED_R → OUTPUT (0)
 *   Others = INPUT by default
 */
#define GPIO_PORTB_DIR       0b00111110   /* RB0=OUT, RB1=IN, RB6,7=OUT */

/*
 * PORTC:
 *   RC6 = TX → OUTPUT (handled by USART peripheral, set as output)
 *   RC7 = RX → INPUT
 *   Others not used → INPUT
 */
#define GPIO_PORTC_DIR       0b10000000   /* RC7=IN(RX), RC6=OUT(TX) */

/*
 * PORTD: LCD (RS,RW,E,D4-D7) + RELAY + BUZZER → all OUTPUT
 */
#define GPIO_PORTD_DIR       0x00         /* All outputs */

/*
 * PORTE: unused
 */
#define GPIO_PORTE_DIR       0xFF

/* ── Initial output values (everything starts LOW / OFF) ── */
#define GPIO_PORTA_INIT_VAL  0x00
#define GPIO_PORTB_INIT_VAL  0x00
#define GPIO_PORTC_INIT_VAL  0x00
#define GPIO_PORTD_INIT_VAL  0x00
#define GPIO_PORTE_INIT_VAL  0x00

#endif /* GPIO_CONFIG_H */
