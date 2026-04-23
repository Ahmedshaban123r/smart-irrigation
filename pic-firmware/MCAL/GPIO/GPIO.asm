
_SetPinDirection:

;GPIO.c,9 :: 		void SetPinDirection(u8 Port, u8 Pin, u8 Direction)
;GPIO.c,11 :: 		switch(Port)
	GOTO       L_SetPinDirection0
;GPIO.c,13 :: 		case GPIO_PORTA:
L_SetPinDirection2:
;GPIO.c,14 :: 		if(Direction == OUTPUT) CLR_BIT(TRISA, Pin);
	MOVF       FARG_SetPinDirection_Direction+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinDirection3
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection69:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection70
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection69
L__SetPinDirection70:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      133, 1
	GOTO       L_SetPinDirection4
L_SetPinDirection3:
;GPIO.c,15 :: 		else                        SET_BIT(TRISA, Pin);
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection71:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection72
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection71
L__SetPinDirection72:
	MOVF       R0+0, 0
	IORWF      133, 1
L_SetPinDirection4:
;GPIO.c,16 :: 		break;
	GOTO       L_SetPinDirection1
;GPIO.c,17 :: 		case GPIO_PORTB:
L_SetPinDirection5:
;GPIO.c,18 :: 		if(Direction == OUTPUT) CLR_BIT(TRISB, Pin);
	MOVF       FARG_SetPinDirection_Direction+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinDirection6
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection73:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection74
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection73
L__SetPinDirection74:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      134, 1
	GOTO       L_SetPinDirection7
L_SetPinDirection6:
;GPIO.c,19 :: 		else                        SET_BIT(TRISB, Pin);
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection75:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection76
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection75
L__SetPinDirection76:
	MOVF       R0+0, 0
	IORWF      134, 1
L_SetPinDirection7:
;GPIO.c,20 :: 		break;
	GOTO       L_SetPinDirection1
;GPIO.c,21 :: 		case GPIO_PORTC:
L_SetPinDirection8:
;GPIO.c,22 :: 		if(Direction == OUTPUT) CLR_BIT(TRISC, Pin);
	MOVF       FARG_SetPinDirection_Direction+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinDirection9
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection77:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection78
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection77
L__SetPinDirection78:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      135, 1
	GOTO       L_SetPinDirection10
L_SetPinDirection9:
;GPIO.c,23 :: 		else                        SET_BIT(TRISC, Pin);
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection79:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection80
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection79
L__SetPinDirection80:
	MOVF       R0+0, 0
	IORWF      135, 1
L_SetPinDirection10:
;GPIO.c,24 :: 		break;
	GOTO       L_SetPinDirection1
;GPIO.c,25 :: 		case GPIO_PORTD:
L_SetPinDirection11:
;GPIO.c,26 :: 		if(Direction == OUTPUT) CLR_BIT(TRISD, Pin);
	MOVF       FARG_SetPinDirection_Direction+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinDirection12
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection81:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection82
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection81
L__SetPinDirection82:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      136, 1
	GOTO       L_SetPinDirection13
L_SetPinDirection12:
;GPIO.c,27 :: 		else                        SET_BIT(TRISD, Pin);
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection83:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection84
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection83
L__SetPinDirection84:
	MOVF       R0+0, 0
	IORWF      136, 1
L_SetPinDirection13:
;GPIO.c,28 :: 		break;
	GOTO       L_SetPinDirection1
;GPIO.c,29 :: 		case GPIO_PORTE:
L_SetPinDirection14:
;GPIO.c,30 :: 		if(Direction == OUTPUT) CLR_BIT(TRISE, Pin);
	MOVF       FARG_SetPinDirection_Direction+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinDirection15
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection85:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection86
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection85
L__SetPinDirection86:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      137, 1
	GOTO       L_SetPinDirection16
L_SetPinDirection15:
;GPIO.c,31 :: 		else                        SET_BIT(TRISE, Pin);
	MOVF       FARG_SetPinDirection_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinDirection87:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinDirection88
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinDirection87
L__SetPinDirection88:
	MOVF       R0+0, 0
	IORWF      137, 1
L_SetPinDirection16:
;GPIO.c,32 :: 		break;
	GOTO       L_SetPinDirection1
;GPIO.c,33 :: 		default: break;
L_SetPinDirection17:
	GOTO       L_SetPinDirection1
;GPIO.c,34 :: 		}
L_SetPinDirection0:
	MOVF       FARG_SetPinDirection_Port+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinDirection2
	MOVF       FARG_SetPinDirection_Port+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinDirection5
	MOVF       FARG_SetPinDirection_Port+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinDirection8
	MOVF       FARG_SetPinDirection_Port+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinDirection11
	MOVF       FARG_SetPinDirection_Port+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinDirection14
	GOTO       L_SetPinDirection17
L_SetPinDirection1:
;GPIO.c,35 :: 		}
L_end_SetPinDirection:
	RETURN
; end of _SetPinDirection

_SetPinValue:

;GPIO.c,37 :: 		void SetPinValue(u8 Port, u8 Pin, u8 Value)
;GPIO.c,39 :: 		switch(Port)
	GOTO       L_SetPinValue18
;GPIO.c,41 :: 		case GPIO_PORTA:
L_SetPinValue20:
;GPIO.c,42 :: 		if(Value == HIGH) SET_BIT(PORTA, Pin);
	MOVF       FARG_SetPinValue_Value+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinValue21
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue90:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue91
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue90
L__SetPinValue91:
	MOVF       R0+0, 0
	IORWF      5, 1
	GOTO       L_SetPinValue22
L_SetPinValue21:
;GPIO.c,43 :: 		else                   CLR_BIT(PORTA, Pin);
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue92:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue93
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue92
L__SetPinValue93:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      5, 1
L_SetPinValue22:
;GPIO.c,44 :: 		break;
	GOTO       L_SetPinValue19
;GPIO.c,45 :: 		case GPIO_PORTB:
L_SetPinValue23:
;GPIO.c,46 :: 		if(Value == HIGH) SET_BIT(PORTB, Pin);
	MOVF       FARG_SetPinValue_Value+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinValue24
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue94:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue95
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue94
L__SetPinValue95:
	MOVF       R0+0, 0
	IORWF      6, 1
	GOTO       L_SetPinValue25
L_SetPinValue24:
;GPIO.c,47 :: 		else                   CLR_BIT(PORTB, Pin);
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue96:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue97
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue96
L__SetPinValue97:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      6, 1
L_SetPinValue25:
;GPIO.c,48 :: 		break;
	GOTO       L_SetPinValue19
;GPIO.c,49 :: 		case GPIO_PORTC:
L_SetPinValue26:
;GPIO.c,50 :: 		if(Value == HIGH) SET_BIT(PORTC, Pin);
	MOVF       FARG_SetPinValue_Value+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinValue27
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue98:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue99
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue98
L__SetPinValue99:
	MOVF       R0+0, 0
	IORWF      7, 1
	GOTO       L_SetPinValue28
L_SetPinValue27:
;GPIO.c,51 :: 		else                   CLR_BIT(PORTC, Pin);
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue100:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue101
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue100
L__SetPinValue101:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      7, 1
L_SetPinValue28:
;GPIO.c,52 :: 		break;
	GOTO       L_SetPinValue19
;GPIO.c,53 :: 		case GPIO_PORTD:
L_SetPinValue29:
;GPIO.c,54 :: 		if(Value == HIGH) SET_BIT(PORTD, Pin);
	MOVF       FARG_SetPinValue_Value+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinValue30
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue102:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue103
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue102
L__SetPinValue103:
	MOVF       R0+0, 0
	IORWF      8, 1
	GOTO       L_SetPinValue31
L_SetPinValue30:
;GPIO.c,55 :: 		else                   CLR_BIT(PORTD, Pin);
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue104:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue105
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue104
L__SetPinValue105:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      8, 1
L_SetPinValue31:
;GPIO.c,56 :: 		break;
	GOTO       L_SetPinValue19
;GPIO.c,57 :: 		case GPIO_PORTE:
L_SetPinValue32:
;GPIO.c,58 :: 		if(Value == HIGH) SET_BIT(PORTE, Pin);
	MOVF       FARG_SetPinValue_Value+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_SetPinValue33
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue106:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue107
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue106
L__SetPinValue107:
	MOVF       R0+0, 0
	IORWF      9, 1
	GOTO       L_SetPinValue34
L_SetPinValue33:
;GPIO.c,59 :: 		else                   CLR_BIT(PORTE, Pin);
	MOVF       FARG_SetPinValue_Pin+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__SetPinValue108:
	BTFSC      STATUS+0, 2
	GOTO       L__SetPinValue109
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__SetPinValue108
L__SetPinValue109:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      9, 1
L_SetPinValue34:
;GPIO.c,60 :: 		break;
	GOTO       L_SetPinValue19
;GPIO.c,61 :: 		default: break;
L_SetPinValue35:
	GOTO       L_SetPinValue19
;GPIO.c,62 :: 		}
L_SetPinValue18:
	MOVF       FARG_SetPinValue_Port+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinValue20
	MOVF       FARG_SetPinValue_Port+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinValue23
	MOVF       FARG_SetPinValue_Port+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinValue26
	MOVF       FARG_SetPinValue_Port+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinValue29
	MOVF       FARG_SetPinValue_Port+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_SetPinValue32
	GOTO       L_SetPinValue35
L_SetPinValue19:
;GPIO.c,63 :: 		}
L_end_SetPinValue:
	RETURN
; end of _SetPinValue

_GetPinValue:

;GPIO.c,65 :: 		u8 GetPinValue(u8 Port, u8 Pin)
;GPIO.c,67 :: 		u8 val = 0;
	CLRF       GetPinValue_val_L0+0
;GPIO.c,68 :: 		switch(Port)
	GOTO       L_GetPinValue36
;GPIO.c,70 :: 		case GPIO_PORTA: val = GET_BIT(PORTA, Pin); break;
L_GetPinValue38:
	MOVF       FARG_GetPinValue_Pin+0, 0
	MOVWF      R0+0
	MOVF       5, 0
	MOVWF      GetPinValue_val_L0+0
	MOVF       R0+0, 0
L__GetPinValue111:
	BTFSC      STATUS+0, 2
	GOTO       L__GetPinValue112
	RRF        GetPinValue_val_L0+0, 1
	BCF        GetPinValue_val_L0+0, 7
	ADDLW      255
	GOTO       L__GetPinValue111
L__GetPinValue112:
	MOVLW      1
	ANDWF      GetPinValue_val_L0+0, 1
	GOTO       L_GetPinValue37
;GPIO.c,71 :: 		case GPIO_PORTB: val = GET_BIT(PORTB, Pin); break;
L_GetPinValue39:
	MOVF       FARG_GetPinValue_Pin+0, 0
	MOVWF      R0+0
	MOVF       6, 0
	MOVWF      GetPinValue_val_L0+0
	MOVF       R0+0, 0
L__GetPinValue113:
	BTFSC      STATUS+0, 2
	GOTO       L__GetPinValue114
	RRF        GetPinValue_val_L0+0, 1
	BCF        GetPinValue_val_L0+0, 7
	ADDLW      255
	GOTO       L__GetPinValue113
L__GetPinValue114:
	MOVLW      1
	ANDWF      GetPinValue_val_L0+0, 1
	GOTO       L_GetPinValue37
;GPIO.c,72 :: 		case GPIO_PORTC: val = GET_BIT(PORTC, Pin); break;
L_GetPinValue40:
	MOVF       FARG_GetPinValue_Pin+0, 0
	MOVWF      R0+0
	MOVF       7, 0
	MOVWF      GetPinValue_val_L0+0
	MOVF       R0+0, 0
L__GetPinValue115:
	BTFSC      STATUS+0, 2
	GOTO       L__GetPinValue116
	RRF        GetPinValue_val_L0+0, 1
	BCF        GetPinValue_val_L0+0, 7
	ADDLW      255
	GOTO       L__GetPinValue115
L__GetPinValue116:
	MOVLW      1
	ANDWF      GetPinValue_val_L0+0, 1
	GOTO       L_GetPinValue37
;GPIO.c,73 :: 		case GPIO_PORTD: val = GET_BIT(PORTD, Pin); break;
L_GetPinValue41:
	MOVF       FARG_GetPinValue_Pin+0, 0
	MOVWF      R0+0
	MOVF       8, 0
	MOVWF      GetPinValue_val_L0+0
	MOVF       R0+0, 0
L__GetPinValue117:
	BTFSC      STATUS+0, 2
	GOTO       L__GetPinValue118
	RRF        GetPinValue_val_L0+0, 1
	BCF        GetPinValue_val_L0+0, 7
	ADDLW      255
	GOTO       L__GetPinValue117
L__GetPinValue118:
	MOVLW      1
	ANDWF      GetPinValue_val_L0+0, 1
	GOTO       L_GetPinValue37
;GPIO.c,74 :: 		case GPIO_PORTE: val = GET_BIT(PORTE, Pin); break;
L_GetPinValue42:
	MOVF       FARG_GetPinValue_Pin+0, 0
	MOVWF      R0+0
	MOVF       9, 0
	MOVWF      GetPinValue_val_L0+0
	MOVF       R0+0, 0
L__GetPinValue119:
	BTFSC      STATUS+0, 2
	GOTO       L__GetPinValue120
	RRF        GetPinValue_val_L0+0, 1
	BCF        GetPinValue_val_L0+0, 7
	ADDLW      255
	GOTO       L__GetPinValue119
L__GetPinValue120:
	MOVLW      1
	ANDWF      GetPinValue_val_L0+0, 1
	GOTO       L_GetPinValue37
;GPIO.c,75 :: 		default: break;
L_GetPinValue43:
	GOTO       L_GetPinValue37
;GPIO.c,76 :: 		}
L_GetPinValue36:
	MOVF       FARG_GetPinValue_Port+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_GetPinValue38
	MOVF       FARG_GetPinValue_Port+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_GetPinValue39
	MOVF       FARG_GetPinValue_Port+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_GetPinValue40
	MOVF       FARG_GetPinValue_Port+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_GetPinValue41
	MOVF       FARG_GetPinValue_Port+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_GetPinValue42
	GOTO       L_GetPinValue43
L_GetPinValue37:
;GPIO.c,77 :: 		return val;
	MOVF       GetPinValue_val_L0+0, 0
	MOVWF      R0+0
;GPIO.c,78 :: 		}
L_end_GetPinValue:
	RETURN
; end of _GetPinValue

_SetPortDirection:

;GPIO.c,80 :: 		void SetPortDirection(u8 Port, u8 Direction)
;GPIO.c,82 :: 		switch(Port)
	GOTO       L_SetPortDirection44
;GPIO.c,84 :: 		case GPIO_PORTA: TRISA = Direction; break;
L_SetPortDirection46:
	MOVF       FARG_SetPortDirection_Direction+0, 0
	MOVWF      133
	GOTO       L_SetPortDirection45
;GPIO.c,85 :: 		case GPIO_PORTB: TRISB = Direction; break;
L_SetPortDirection47:
	MOVF       FARG_SetPortDirection_Direction+0, 0
	MOVWF      134
	GOTO       L_SetPortDirection45
;GPIO.c,86 :: 		case GPIO_PORTC: TRISC = Direction; break;
L_SetPortDirection48:
	MOVF       FARG_SetPortDirection_Direction+0, 0
	MOVWF      135
	GOTO       L_SetPortDirection45
;GPIO.c,87 :: 		case GPIO_PORTD: TRISD = Direction; break;
L_SetPortDirection49:
	MOVF       FARG_SetPortDirection_Direction+0, 0
	MOVWF      136
	GOTO       L_SetPortDirection45
;GPIO.c,88 :: 		case GPIO_PORTE: TRISE = Direction; break;
L_SetPortDirection50:
	MOVF       FARG_SetPortDirection_Direction+0, 0
	MOVWF      137
	GOTO       L_SetPortDirection45
;GPIO.c,89 :: 		default: break;
L_SetPortDirection51:
	GOTO       L_SetPortDirection45
;GPIO.c,90 :: 		}
L_SetPortDirection44:
	MOVF       FARG_SetPortDirection_Port+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortDirection46
	MOVF       FARG_SetPortDirection_Port+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortDirection47
	MOVF       FARG_SetPortDirection_Port+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortDirection48
	MOVF       FARG_SetPortDirection_Port+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortDirection49
	MOVF       FARG_SetPortDirection_Port+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortDirection50
	GOTO       L_SetPortDirection51
L_SetPortDirection45:
;GPIO.c,91 :: 		}
L_end_SetPortDirection:
	RETURN
; end of _SetPortDirection

_SetPortValue:

;GPIO.c,93 :: 		void SetPortValue(u8 Port, u8 Value)
;GPIO.c,95 :: 		switch(Port)
	GOTO       L_SetPortValue52
;GPIO.c,97 :: 		case GPIO_PORTA: PORTA = Value; break;
L_SetPortValue54:
	MOVF       FARG_SetPortValue_Value+0, 0
	MOVWF      5
	GOTO       L_SetPortValue53
;GPIO.c,98 :: 		case GPIO_PORTB: PORTB = Value; break;
L_SetPortValue55:
	MOVF       FARG_SetPortValue_Value+0, 0
	MOVWF      6
	GOTO       L_SetPortValue53
;GPIO.c,99 :: 		case GPIO_PORTC: PORTC = Value; break;
L_SetPortValue56:
	MOVF       FARG_SetPortValue_Value+0, 0
	MOVWF      7
	GOTO       L_SetPortValue53
;GPIO.c,100 :: 		case GPIO_PORTD: PORTD = Value; break;
L_SetPortValue57:
	MOVF       FARG_SetPortValue_Value+0, 0
	MOVWF      8
	GOTO       L_SetPortValue53
;GPIO.c,101 :: 		case GPIO_PORTE: PORTE = Value; break;
L_SetPortValue58:
	MOVF       FARG_SetPortValue_Value+0, 0
	MOVWF      9
	GOTO       L_SetPortValue53
;GPIO.c,102 :: 		default: break;
L_SetPortValue59:
	GOTO       L_SetPortValue53
;GPIO.c,103 :: 		}
L_SetPortValue52:
	MOVF       FARG_SetPortValue_Port+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortValue54
	MOVF       FARG_SetPortValue_Port+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortValue55
	MOVF       FARG_SetPortValue_Port+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortValue56
	MOVF       FARG_SetPortValue_Port+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortValue57
	MOVF       FARG_SetPortValue_Port+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_SetPortValue58
	GOTO       L_SetPortValue59
L_SetPortValue53:
;GPIO.c,104 :: 		}
L_end_SetPortValue:
	RETURN
; end of _SetPortValue

_GetPortValue:

;GPIO.c,106 :: 		u8 GetPortValue(u8 Port)
;GPIO.c,108 :: 		switch(Port)
	GOTO       L_GetPortValue60
;GPIO.c,110 :: 		case GPIO_PORTA: return PORTA;
L_GetPortValue62:
	MOVF       5, 0
	MOVWF      R0+0
	GOTO       L_end_GetPortValue
;GPIO.c,111 :: 		case GPIO_PORTB: return PORTB;
L_GetPortValue63:
	MOVF       6, 0
	MOVWF      R0+0
	GOTO       L_end_GetPortValue
;GPIO.c,112 :: 		case GPIO_PORTC: return PORTC;
L_GetPortValue64:
	MOVF       7, 0
	MOVWF      R0+0
	GOTO       L_end_GetPortValue
;GPIO.c,113 :: 		case GPIO_PORTD: return PORTD;
L_GetPortValue65:
	MOVF       8, 0
	MOVWF      R0+0
	GOTO       L_end_GetPortValue
;GPIO.c,114 :: 		case GPIO_PORTE: return PORTE;
L_GetPortValue66:
	MOVF       9, 0
	MOVWF      R0+0
	GOTO       L_end_GetPortValue
;GPIO.c,115 :: 		default: return 0;
L_GetPortValue67:
	CLRF       R0+0
	GOTO       L_end_GetPortValue
;GPIO.c,116 :: 		}
L_GetPortValue60:
	MOVF       FARG_GetPortValue_Port+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_GetPortValue62
	MOVF       FARG_GetPortValue_Port+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_GetPortValue63
	MOVF       FARG_GetPortValue_Port+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_GetPortValue64
	MOVF       FARG_GetPortValue_Port+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_GetPortValue65
	MOVF       FARG_GetPortValue_Port+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_GetPortValue66
	GOTO       L_GetPortValue67
;GPIO.c,117 :: 		}
L_end_GetPortValue:
	RETURN
; end of _GetPortValue

_GPIO_Init:

;GPIO.c,119 :: 		void GPIO_Init(void)
;GPIO.c,121 :: 		TRISA = GPIO_PORTA_DIR;
	MOVLW      255
	MOVWF      133
;GPIO.c,122 :: 		TRISB = GPIO_PORTB_DIR;
	MOVLW      62
	MOVWF      134
;GPIO.c,123 :: 		TRISC = GPIO_PORTC_DIR;
	MOVLW      128
	MOVWF      135
;GPIO.c,124 :: 		TRISD = GPIO_PORTD_DIR;
	CLRF       136
;GPIO.c,125 :: 		TRISE = GPIO_PORTE_DIR;
	MOVLW      255
	MOVWF      137
;GPIO.c,127 :: 		PORTA = GPIO_PORTA_INIT_VAL;
	CLRF       5
;GPIO.c,128 :: 		PORTB = GPIO_PORTB_INIT_VAL;
	CLRF       6
;GPIO.c,129 :: 		PORTC = GPIO_PORTC_INIT_VAL;
	CLRF       7
;GPIO.c,130 :: 		PORTD = GPIO_PORTD_INIT_VAL;
	CLRF       8
;GPIO.c,131 :: 		PORTE = GPIO_PORTE_INIT_VAL;
	CLRF       9
;GPIO.c,132 :: 		}
L_end_GPIO_Init:
	RETURN
; end of _GPIO_Init
