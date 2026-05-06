
_Generic_Delay_ms:

;Delay.c,9 :: 		void Generic_Delay_ms(u16 ms)
;Delay.c,14 :: 		for(i = 0; i < ms; i++)
	CLRF       R1+0
L_Generic_Delay_ms0:
	MOVF       FARG_Generic_Delay_ms_ms+0, 0
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Generic_Delay_ms1
;Delay.c,19 :: 		for(j = 0; j < 180; j++)
	CLRF       R2+0
L_Generic_Delay_ms3:
	MOVLW      180
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Generic_Delay_ms4
	INCF       R2+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R2+0
;Delay.c,22 :: 		}
	GOTO       L_Generic_Delay_ms3
L_Generic_Delay_ms4:
;Delay.c,14 :: 		for(i = 0; i < ms; i++)
	INCF       R1+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R1+0
;Delay.c,23 :: 		}
	GOTO       L_Generic_Delay_ms0
L_Generic_Delay_ms1:
;Delay.c,24 :: 		}
L_end_Generic_Delay_ms:
	RETURN
; end of _Generic_Delay_ms

_Generic_Delay_us:

;Delay.c,26 :: 		void Generic_Delay_us(u16 us)
;Delay.c,30 :: 		for(i = 0; i < us; i++)
	CLRF       R1+0
L_Generic_Delay_us6:
	MOVF       FARG_Generic_Delay_us_us+0, 0
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Generic_Delay_us7
;Delay.c,35 :: 		for(j = 0; j < 2; j++)
	CLRF       R2+0
L_Generic_Delay_us9:
	MOVLW      2
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Generic_Delay_us10
	INCF       R2+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R2+0
;Delay.c,38 :: 		}
	GOTO       L_Generic_Delay_us9
L_Generic_Delay_us10:
;Delay.c,30 :: 		for(i = 0; i < us; i++)
	INCF       R1+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R1+0
;Delay.c,39 :: 		}
	GOTO       L_Generic_Delay_us6
L_Generic_Delay_us7:
;Delay.c,40 :: 		}
L_end_Generic_Delay_us:
	RETURN
; end of _Generic_Delay_us
