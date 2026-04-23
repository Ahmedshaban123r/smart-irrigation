
_UART_RX_Init:

;USART.c,14 :: 		void UART_RX_Init(void)
;USART.c,17 :: 		SET_BIT(TXSTA , BRGH);      // High Speed Mode
	BSF        152, 2
;USART.c,19 :: 		SPBRG = 51;                 // 9600 Baud @ 8MHz: (8000000/(16*9600))-1 = 51 → 9615 baud (0.16% error)
	MOVLW      51
	MOVWF      153
;USART.c,21 :: 		CLR_BIT(TXSTA , SYNC);      // Asynchronous Mode
	MOVLW      239
	ANDWF      152, 1
;USART.c,23 :: 		SET_BIT(RCSTA , SPEN);      // Enable Serial Port
	BSF        24, 7
;USART.c,25 :: 		SET_BIT(RCSTA , CREN);      // Continuous Receive
	BSF        24, 4
;USART.c,27 :: 		SET_BIT(PIE1 , RCIE);       // Enable UART RX Interrupt
	BSF        140, 5
;USART.c,29 :: 		SET_BIT(INTCON , PEIE);     // Peripheral Interrupt Enable
	BSF        11, 6
;USART.c,30 :: 		SET_BIT(INTCON , GIE);      // Global Interrupt Enable
	BSF        11, 7
;USART.c,31 :: 		}
L_end_UART_RX_Init:
	RETURN
; end of _UART_RX_Init

_UART_TX_Init:

;USART.c,37 :: 		void UART_TX_Init(void)
;USART.c,40 :: 		SET_BIT(TXSTA , BRGH);      // High Speed
	BSF        152, 2
;USART.c,42 :: 		SPBRG = 51;                 // 9600 Baud @ 8MHz: (8000000/(16*9600))-1 = 51 → 9615 baud (0.16% error)
	MOVLW      51
	MOVWF      153
;USART.c,44 :: 		CLR_BIT(TXSTA , SYNC);      // Asynchronous Mode
	MOVLW      239
	ANDWF      152, 1
;USART.c,46 :: 		SET_BIT(RCSTA , SPEN);      // Enable Serial Port
	BSF        24, 7
;USART.c,48 :: 		SET_BIT(TXSTA , TXEN);      // Enable Transmission
	BSF        152, 5
;USART.c,49 :: 		}
L_end_UART_TX_Init:
	RETURN
; end of _UART_TX_Init

_UART_Write:

;USART.c,55 :: 		void UART_Write(u8 Data)
;USART.c,58 :: 		while(!GET_BIT(TXSTA , TRMT));   // Wait until TX empty
L_UART_Write0:
	MOVF       152, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSC      R1+0, 0
	GOTO       L_UART_Write1
	GOTO       L_UART_Write0
L_UART_Write1:
;USART.c,60 :: 		TXREG = Data;
	MOVF       FARG_UART_Write_Data+0, 0
	MOVWF      25
;USART.c,61 :: 		}
L_end_UART_Write:
	RETURN
; end of _UART_Write

_UART_Write_ISR:

;USART.c,63 :: 		void UART_Write_ISR(u8 Data) {
;USART.c,64 :: 		while(!GET_BIT(TXSTA , TRMT));   // Wait until TX empty
L_UART_Write_ISR2:
	MOVF       152, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSC      R1+0, 0
	GOTO       L_UART_Write_ISR3
	GOTO       L_UART_Write_ISR2
L_UART_Write_ISR3:
;USART.c,66 :: 		TXREG = Data;
	MOVF       FARG_UART_Write_ISR_Data+0, 0
	MOVWF      25
;USART.c,67 :: 		}
L_end_UART_Write_ISR:
	RETURN
; end of _UART_Write_ISR

_UART_Read:

;USART.c,73 :: 		u8 UART_Read(void)
;USART.c,76 :: 		while(!GET_BIT(PIR1 , RCIF));    // Wait for data
L_UART_Read4:
	MOVLW      5
	MOVWF      R0+0
	MOVF       12, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__UART_Read15:
	BTFSC      STATUS+0, 2
	GOTO       L__UART_Read16
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__UART_Read15
L__UART_Read16:
	BTFSC      R1+0, 0
	GOTO       L_UART_Read5
	GOTO       L_UART_Read4
L_UART_Read5:
;USART.c,78 :: 		return RCREG;
	MOVF       26, 0
	MOVWF      R0+0
;USART.c,79 :: 		}
L_end_UART_Read:
	RETURN
; end of _UART_Read

_UART_TX_Empty:

;USART.c,85 :: 		u8 UART_TX_Empty(void)
;USART.c,88 :: 		return GET_BIT(TXSTA , TRMT);
	MOVF       152, 0
	MOVWF      R0+0
	RRF        R0+0, 1
	BCF        R0+0, 7
	MOVLW      1
	ANDWF      R0+0, 1
;USART.c,89 :: 		}
L_end_UART_TX_Empty:
	RETURN
; end of _UART_TX_Empty

_UART_SetCallback:

;USART.c,95 :: 		void UART_SetCallback(void (*Callback)(u8))
;USART.c,98 :: 		if(Callback != 0)
	MOVF       FARG_UART_SetCallback_Callback+0, 0
	MOVWF      R1+0
	MOVF       FARG_UART_SetCallback_Callback+1, 0
	MOVWF      R1+1
	MOVF       FARG_UART_SetCallback_Callback+2, 0
	MOVWF      R1+2
	MOVF       FARG_UART_SetCallback_Callback+3, 0
	MOVWF      R1+3
	MOVLW      0
	MOVWF      R0+0
	XORWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_SetCallback19
	MOVF       R0+0, 0
	XORWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_SetCallback19
	MOVF       R0+0, 0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_SetCallback19
	MOVF       R1+0, 0
	XORLW      0
L__UART_SetCallback19:
	BTFSC      STATUS+0, 2
	GOTO       L_UART_SetCallback6
;USART.c,100 :: 		UART_Callback = Callback;
	MOVF       FARG_UART_SetCallback_Callback+0, 0
	MOVWF      USART_UART_Callback+0
	MOVF       FARG_UART_SetCallback_Callback+1, 0
	MOVWF      USART_UART_Callback+1
	MOVF       FARG_UART_SetCallback_Callback+2, 0
	MOVWF      USART_UART_Callback+2
	MOVF       FARG_UART_SetCallback_Callback+3, 0
;USART.c,101 :: 		}
L_UART_SetCallback6:
;USART.c,103 :: 		}
L_end_UART_SetCallback:
	RETURN
; end of _UART_SetCallback

_UART_ISR:

;USART.c,105 :: 		void UART_ISR(void)
;USART.c,108 :: 		u8 UART_data = RCREG;   //
	MOVF       26, 0
	MOVWF      UART_ISR_UART_data_L0+0
;USART.c,109 :: 		if(UART_Callback != 0)
	MOVF       USART_UART_Callback+0, 0
	MOVWF      R1+0
	MOVF       USART_UART_Callback+1, 0
	MOVWF      R1+1
	MOVF       USART_UART_Callback+2, 0
	MOVWF      R1+2
	MOVF       USART_UART_Callback+3, 0
	MOVWF      R1+3
	MOVLW      0
	MOVWF      R0+0
	XORWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_ISR21
	MOVF       R0+0, 0
	XORWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_ISR21
	MOVF       R0+0, 0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__UART_ISR21
	MOVF       R1+0, 0
	XORLW      0
L__UART_ISR21:
	BTFSC      STATUS+0, 2
	GOTO       L_UART_ISR7
;USART.c,111 :: 		UART_Callback(UART_data);   //
	MOVF       USART_UART_Callback+2, 0
	MOVWF      FSR
	MOVF       UART_ISR_UART_data_L0+0, 0
	MOVWF      INDF+0
	INCF       FSR, 1
	MOVF       USART_UART_Callback+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       USART_UART_Callback+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoIFC+0
;USART.c,112 :: 		}
L_UART_ISR7:
;USART.c,114 :: 		}
L_end_UART_ISR:
	RETURN
; end of _UART_ISR

_UART_WriteString:

;USART.c,116 :: 		void UART_WriteString(char *str)
;USART.c,118 :: 		while(*str)
L_UART_WriteString8:
	MOVF       FARG_UART_WriteString_str+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_UART_WriteString9
;USART.c,120 :: 		UART_Write(*str++);
	MOVF       FARG_UART_WriteString_str+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART_Write_Data+0
	CALL       _UART_Write+0
	INCF       FARG_UART_WriteString_str+0, 1
;USART.c,121 :: 		}
	GOTO       L_UART_WriteString8
L_UART_WriteString9:
;USART.c,122 :: 		}
L_end_UART_WriteString:
	RETURN
; end of _UART_WriteString
