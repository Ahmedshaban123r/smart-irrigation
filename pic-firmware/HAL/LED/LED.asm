
_LED_Init:

;LED.c,4 :: 		void LED_Init(u8 Port, u8 Pin)
;LED.c,6 :: 		SetPinDirection(Port, Pin, OUTPUT);
	MOVF       FARG_LED_Init_Port+0, 0
	MOVWF      FARG_SetPinDirection_Port+0
	MOVF       FARG_LED_Init_Pin+0, 0
	MOVWF      FARG_SetPinDirection_Pin+0
	CLRF       FARG_SetPinDirection_Direction+0
	CALL       _SetPinDirection+0
;LED.c,7 :: 		}
L_end_LED_Init:
	RETURN
; end of _LED_Init

_LED_On:

;LED.c,9 :: 		void LED_On(u8 Port, u8 Pin)
;LED.c,11 :: 		SetPinValue(Port, Pin, HIGH);
	MOVF       FARG_LED_On_Port+0, 0
	MOVWF      FARG_SetPinValue_Port+0
	MOVF       FARG_LED_On_Pin+0, 0
	MOVWF      FARG_SetPinValue_Pin+0
	MOVLW      1
	MOVWF      FARG_SetPinValue_Value+0
	CALL       _SetPinValue+0
;LED.c,12 :: 		}
L_end_LED_On:
	RETURN
; end of _LED_On

_LED_Off:

;LED.c,14 :: 		void LED_Off(u8 Port, u8 Pin)
;LED.c,16 :: 		SetPinValue(Port, Pin, LOW);
	MOVF       FARG_LED_Off_Port+0, 0
	MOVWF      FARG_SetPinValue_Port+0
	MOVF       FARG_LED_Off_Pin+0, 0
	MOVWF      FARG_SetPinValue_Pin+0
	CLRF       FARG_SetPinValue_Value+0
	CALL       _SetPinValue+0
;LED.c,17 :: 		}
L_end_LED_Off:
	RETURN
; end of _LED_Off

_LED_Toggle:

;LED.c,19 :: 		void LED_Toggle(u8 Port, u8 Pin)
;LED.c,21 :: 		if(GetPinValue(Port, Pin) == HIGH)
	MOVF       FARG_LED_Toggle_Port+0, 0
	MOVWF      FARG_GetPinValue_Port+0
	MOVF       FARG_LED_Toggle_Pin+0, 0
	MOVWF      FARG_GetPinValue_Pin+0
	CALL       _GetPinValue+0
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_LED_Toggle0
;LED.c,22 :: 		SetPinValue(Port, Pin, LOW);
	MOVF       FARG_LED_Toggle_Port+0, 0
	MOVWF      FARG_SetPinValue_Port+0
	MOVF       FARG_LED_Toggle_Pin+0, 0
	MOVWF      FARG_SetPinValue_Pin+0
	CLRF       FARG_SetPinValue_Value+0
	CALL       _SetPinValue+0
	GOTO       L_LED_Toggle1
L_LED_Toggle0:
;LED.c,24 :: 		SetPinValue(Port, Pin, HIGH);
	MOVF       FARG_LED_Toggle_Port+0, 0
	MOVWF      FARG_SetPinValue_Port+0
	MOVF       FARG_LED_Toggle_Pin+0, 0
	MOVWF      FARG_SetPinValue_Pin+0
	MOVLW      1
	MOVWF      FARG_SetPinValue_Value+0
	CALL       _SetPinValue+0
L_LED_Toggle1:
;LED.c,25 :: 		}
L_end_LED_Toggle:
	RETURN
; end of _LED_Toggle
