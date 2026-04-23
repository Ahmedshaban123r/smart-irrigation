
_Buzzer_Init:

;Buzzer.c,15 :: 		void Buzzer_Init(void)
;Buzzer.c,17 :: 		CLR_BIT(BUZZER_TRIS, BUZZER_PIN); /* Output */
	MOVLW      253
	ANDWF      136, 1
;Buzzer.c,18 :: 		CLR_BIT(BUZZER_PORT, BUZZER_PIN); /* LOW */
	MOVLW      253
	ANDWF      8, 1
;Buzzer.c,19 :: 		}
L_end_Buzzer_Init:
	RETURN
; end of _Buzzer_Init

_Buzzer_On:

;Buzzer.c,21 :: 		void Buzzer_On(void)
;Buzzer.c,23 :: 		SET_BIT(BUZZER_PORT, BUZZER_PIN);
	BSF        8, 1
;Buzzer.c,24 :: 		}
L_end_Buzzer_On:
	RETURN
; end of _Buzzer_On

_Buzzer_Off:

;Buzzer.c,26 :: 		void Buzzer_Off(void)
;Buzzer.c,28 :: 		CLR_BIT(BUZZER_PORT, BUZZER_PIN);
	MOVLW      253
	ANDWF      8, 1
;Buzzer.c,29 :: 		}
L_end_Buzzer_Off:
	RETURN
; end of _Buzzer_Off

_Buzzer_Beep:

;Buzzer.c,31 :: 		void Buzzer_Beep(u16 duration_ms)
;Buzzer.c,33 :: 		Buzzer_On();
	CALL       _Buzzer_On+0
;Buzzer.c,34 :: 		Generic_Delay_ms(duration_ms); /* Using generic delay */
	MOVF       FARG_Buzzer_Beep_duration_ms+0, 0
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;Buzzer.c,35 :: 		Buzzer_Off();
	CALL       _Buzzer_Off+0
;Buzzer.c,36 :: 		}
L_end_Buzzer_Beep:
	RETURN
; end of _Buzzer_Beep

_Buzzer_BeepN:

;Buzzer.c,38 :: 		void Buzzer_BeepN(u8 count, u16 ms_on, u16 ms_off)
;Buzzer.c,40 :: 		u8 i = 0u;
	CLRF       Buzzer_BeepN_i_L0+0
;Buzzer.c,41 :: 		for(i = 0u; i < count; i++)
	CLRF       Buzzer_BeepN_i_L0+0
L_Buzzer_BeepN0:
	MOVF       FARG_Buzzer_BeepN_count+0, 0
	SUBWF      Buzzer_BeepN_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Buzzer_BeepN1
;Buzzer.c,43 :: 		Buzzer_On();
	CALL       _Buzzer_On+0
;Buzzer.c,44 :: 		Generic_Delay_ms(ms_on); /* Using generic delay */
	MOVF       FARG_Buzzer_BeepN_ms_on+0, 0
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;Buzzer.c,45 :: 		Buzzer_Off();
	CALL       _Buzzer_Off+0
;Buzzer.c,47 :: 		if(i < (u8)(count - 1u))
	DECF       FARG_Buzzer_BeepN_count+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	SUBWF      Buzzer_BeepN_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Buzzer_BeepN3
;Buzzer.c,49 :: 		Generic_Delay_ms(ms_off); /* Using generic delay */
	MOVF       FARG_Buzzer_BeepN_ms_off+0, 0
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;Buzzer.c,50 :: 		}
L_Buzzer_BeepN3:
;Buzzer.c,41 :: 		for(i = 0u; i < count; i++)
	INCF       Buzzer_BeepN_i_L0+0, 1
;Buzzer.c,51 :: 		}
	GOTO       L_Buzzer_BeepN0
L_Buzzer_BeepN1:
;Buzzer.c,52 :: 		}
L_end_Buzzer_BeepN:
	RETURN
; end of _Buzzer_BeepN
