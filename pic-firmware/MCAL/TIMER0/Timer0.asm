
_TMR0_Init:

;Timer0.c,25 :: 		void TMR0_Init(void)
;Timer0.c,27 :: 		CLR_BIT(OPTION_REG, T0CS);   /* Internal clock source     */
	MOVLW      223
	ANDWF      129, 1
;Timer0.c,28 :: 		CLR_BIT(OPTION_REG, PSA);    /* Prescaler assigned to TMR0*/
	MOVLW      247
	ANDWF      129, 1
;Timer0.c,29 :: 		SET_BIT(OPTION_REG, PS2);    /* PS2:PS0 = 111 → div 256   */
	BSF        129, 2
;Timer0.c,30 :: 		SET_BIT(OPTION_REG, PS1);
	BSF        129, 1
;Timer0.c,31 :: 		SET_BIT(OPTION_REG, PS0);
	BSF        129, 0
;Timer0.c,32 :: 		CLR_BIT(INTCON, TMR0IF);     /* Clear overflow flag        */
	MOVLW      251
	ANDWF      11, 1
;Timer0.c,33 :: 		}
L_end_TMR0_Init:
	RETURN
; end of _TMR0_Init

_TMR0_Enable:

;Timer0.c,36 :: 		void TMR0_Enable(void)  { SET_BIT(INTCON, TMR0IE); }
	BSF        11, 5
L_end_TMR0_Enable:
	RETURN
; end of _TMR0_Enable

_TMR0_Disable:

;Timer0.c,37 :: 		void TMR0_Disable(void) { CLR_BIT(INTCON, TMR0IE); }
	MOVLW      223
	ANDWF      11, 1
L_end_TMR0_Disable:
	RETURN
; end of _TMR0_Disable

_TMR0_Reset:

;Timer0.c,38 :: 		void TMR0_Reset(void)   { TMR0 = 0; }
	CLRF       1
L_end_TMR0_Reset:
	RETURN
; end of _TMR0_Reset

_TMR0_SetInterval_s:

;Timer0.c,41 :: 		void TMR0_SetInterval_s(u8 seconds)
;Timer0.c,46 :: 		u32 total_ticks  = (u32)seconds * 7812UL;
	MOVF       FARG_TMR0_SetInterval_s_seconds+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	CLRF       R0+2
	CLRF       R0+3
	MOVLW      132
	MOVWF      R4+0
	MOVLW      30
	MOVWF      R4+1
	MOVLW      0
	MOVWF      R4+2
	MOVLW      0
	MOVWF      R4+3
	CALL       _Mul_32x32_U+0
;Timer0.c,47 :: 		u8  remainder    = (u8)(total_ticks % 256u);
	MOVLW      255
	ANDWF      R0+0, 0
	MOVWF      R5+0
	MOVF       R0+1, 0
	MOVWF      R5+1
	MOVF       R0+2, 0
	MOVWF      R5+2
	MOVF       R0+3, 0
	MOVWF      R5+3
	MOVLW      0
	ANDWF      R5+1, 1
	ANDWF      R5+2, 1
	ANDWF      R5+3, 1
;Timer0.c,48 :: 		overflows_needed = total_ticks / 256u;
	MOVF       R0+1, 0
	MOVWF      Timer0_overflows_needed+0
	MOVF       R0+2, 0
	MOVWF      Timer0_overflows_needed+1
	MOVF       R0+3, 0
	MOVWF      Timer0_overflows_needed+2
	CLRF       Timer0_overflows_needed+3
;Timer0.c,49 :: 		jump_value       = (u8)(256u - remainder);
	MOVF       R5+0, 0
	SUBLW      0
	MOVWF      Timer0_jump_value+0
;Timer0.c,50 :: 		current_overflows = 0;
	CLRF       Timer0_current_overflows+0
	CLRF       Timer0_current_overflows+1
	CLRF       Timer0_current_overflows+2
	CLRF       Timer0_current_overflows+3
;Timer0.c,51 :: 		}
L_end_TMR0_SetInterval_s:
	RETURN
; end of _TMR0_SetInterval_s

_TMR0_SetInterval_ms:

;Timer0.c,54 :: 		void TMR0_SetInterval_ms(u16 milliseconds)
;Timer0.c,61 :: 		u32 total_ticks  = ((u32)milliseconds * 7812UL) / 1000UL;
	MOVF       FARG_TMR0_SetInterval_ms_milliseconds+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	CLRF       R0+2
	CLRF       R0+3
	MOVLW      132
	MOVWF      R4+0
	MOVLW      30
	MOVWF      R4+1
	MOVLW      0
	MOVWF      R4+2
	MOVLW      0
	MOVWF      R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	MOVLW      0
	MOVWF      R4+2
	MOVLW      0
	MOVWF      R4+3
	CALL       _Div_32x32_U+0
;Timer0.c,62 :: 		u8  remainder    = (u8)(total_ticks % 256u);
	MOVLW      255
	ANDWF      R0+0, 0
	MOVWF      R5+0
	MOVF       R0+1, 0
	MOVWF      R5+1
	MOVF       R0+2, 0
	MOVWF      R5+2
	MOVF       R0+3, 0
	MOVWF      R5+3
	MOVLW      0
	ANDWF      R5+1, 1
	ANDWF      R5+2, 1
	ANDWF      R5+3, 1
;Timer0.c,63 :: 		overflows_needed = total_ticks / 256u;
	MOVF       R0+1, 0
	MOVWF      Timer0_overflows_needed+0
	MOVF       R0+2, 0
	MOVWF      Timer0_overflows_needed+1
	MOVF       R0+3, 0
	MOVWF      Timer0_overflows_needed+2
	CLRF       Timer0_overflows_needed+3
;Timer0.c,64 :: 		jump_value       = (u8)(256u - remainder);
	MOVF       R5+0, 0
	SUBLW      0
	MOVWF      Timer0_jump_value+0
;Timer0.c,65 :: 		current_overflows = 0;
	CLRF       Timer0_current_overflows+0
	CLRF       Timer0_current_overflows+1
	CLRF       Timer0_current_overflows+2
	CLRF       Timer0_current_overflows+3
;Timer0.c,66 :: 		}
L_end_TMR0_SetInterval_ms:
	RETURN
; end of _TMR0_SetInterval_ms

_TMR0_SetCallback:

;Timer0.c,69 :: 		void TMR0_SetCallback(void (*ptr)(void))
;Timer0.c,71 :: 		if(ptr != 0)
	MOVF       FARG_TMR0_SetCallback_ptr+0, 0
	MOVWF      R1+0
	MOVF       FARG_TMR0_SetCallback_ptr+1, 0
	MOVWF      R1+1
	MOVF       FARG_TMR0_SetCallback_ptr+2, 0
	MOVWF      R1+2
	MOVF       FARG_TMR0_SetCallback_ptr+3, 0
	MOVWF      R1+3
	MOVLW      0
	MOVWF      R0+0
	XORWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TMR0_SetCallback12
	MOVF       R0+0, 0
	XORWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TMR0_SetCallback12
	MOVF       R0+0, 0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TMR0_SetCallback12
	MOVF       R1+0, 0
	XORLW      0
L__TMR0_SetCallback12:
	BTFSC      STATUS+0, 2
	GOTO       L_TMR0_SetCallback0
;Timer0.c,73 :: 		TMR0_Callback = ptr;
	MOVF       FARG_TMR0_SetCallback_ptr+0, 0
	MOVWF      Timer0_TMR0_Callback+0
	MOVF       FARG_TMR0_SetCallback_ptr+1, 0
	MOVWF      Timer0_TMR0_Callback+1
	MOVF       FARG_TMR0_SetCallback_ptr+2, 0
	MOVWF      Timer0_TMR0_Callback+2
	MOVF       FARG_TMR0_SetCallback_ptr+3, 0
;Timer0.c,74 :: 		}
L_TMR0_SetCallback0:
;Timer0.c,75 :: 		}
L_end_TMR0_SetCallback:
	RETURN
; end of _TMR0_SetCallback

_TIMER0_ISR:

;Timer0.c,78 :: 		void TIMER0_ISR(void)
;Timer0.c,80 :: 		current_overflows++;
	MOVF       Timer0_current_overflows+0, 0
	MOVWF      R0+0
	MOVF       Timer0_current_overflows+1, 0
	MOVWF      R0+1
	MOVF       Timer0_current_overflows+2, 0
	MOVWF      R0+2
	MOVF       Timer0_current_overflows+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      Timer0_current_overflows+0
	MOVF       R0+1, 0
	MOVWF      Timer0_current_overflows+1
	MOVF       R0+2, 0
	MOVWF      Timer0_current_overflows+2
	MOVF       R0+3, 0
	MOVWF      Timer0_current_overflows+3
;Timer0.c,82 :: 		if(current_overflows == overflows_needed)
	MOVF       Timer0_current_overflows+3, 0
	XORWF      Timer0_overflows_needed+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR14
	MOVF       Timer0_current_overflows+2, 0
	XORWF      Timer0_overflows_needed+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR14
	MOVF       Timer0_current_overflows+1, 0
	XORWF      Timer0_overflows_needed+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR14
	MOVF       Timer0_current_overflows+0, 0
	XORWF      Timer0_overflows_needed+0, 0
L__TIMER0_ISR14:
	BTFSS      STATUS+0, 2
	GOTO       L_TIMER0_ISR1
;Timer0.c,84 :: 		TMR0 = jump_value;
	MOVF       Timer0_jump_value+0, 0
	MOVWF      1
;Timer0.c,85 :: 		}
	GOTO       L_TIMER0_ISR2
L_TIMER0_ISR1:
;Timer0.c,86 :: 		else if(current_overflows > overflows_needed)
	MOVF       Timer0_current_overflows+3, 0
	SUBWF      Timer0_overflows_needed+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR15
	MOVF       Timer0_current_overflows+2, 0
	SUBWF      Timer0_overflows_needed+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR15
	MOVF       Timer0_current_overflows+1, 0
	SUBWF      Timer0_overflows_needed+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR15
	MOVF       Timer0_current_overflows+0, 0
	SUBWF      Timer0_overflows_needed+0, 0
L__TIMER0_ISR15:
	BTFSC      STATUS+0, 0
	GOTO       L_TIMER0_ISR3
;Timer0.c,88 :: 		current_overflows = 0;
	CLRF       Timer0_current_overflows+0
	CLRF       Timer0_current_overflows+1
	CLRF       Timer0_current_overflows+2
	CLRF       Timer0_current_overflows+3
;Timer0.c,89 :: 		if(TMR0_Callback != 0)
	MOVF       Timer0_TMR0_Callback+0, 0
	MOVWF      R1+0
	MOVF       Timer0_TMR0_Callback+1, 0
	MOVWF      R1+1
	MOVF       Timer0_TMR0_Callback+2, 0
	MOVWF      R1+2
	MOVF       Timer0_TMR0_Callback+3, 0
	MOVWF      R1+3
	MOVLW      0
	MOVWF      R0+0
	XORWF      R1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR16
	MOVF       R0+0, 0
	XORWF      R1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR16
	MOVF       R0+0, 0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__TIMER0_ISR16
	MOVF       R1+0, 0
	XORLW      0
L__TIMER0_ISR16:
	BTFSC      STATUS+0, 2
	GOTO       L_TIMER0_ISR4
;Timer0.c,91 :: 		TMR0_Callback();
	MOVF       Timer0_TMR0_Callback+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       Timer0_TMR0_Callback+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoIFC+0
;Timer0.c,92 :: 		}
L_TIMER0_ISR4:
;Timer0.c,93 :: 		}
L_TIMER0_ISR3:
L_TIMER0_ISR2:
;Timer0.c,95 :: 		CLR_BIT(INTCON, TMR0IF);
	MOVLW      251
	ANDWF      11, 1
;Timer0.c,96 :: 		}
L_end_TIMER0_ISR:
	RETURN
; end of _TIMER0_ISR
