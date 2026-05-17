
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;Interrupt_Manager.c,21 :: 		INTERRUPT_ROUTINE
;Interrupt_Manager.c,24 :: 		if (GET_BIT(INTCON, TMR0IF)) {
	MOVF       11, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSS      R1+0, 0
	GOTO       L_interrupt0
;Interrupt_Manager.c,26 :: 		CLR_BIT(INTCON, TMR0IF); /* Clear flag */
	MOVLW      251
	ANDWF      11, 1
;Interrupt_Manager.c,27 :: 		g_tick_100ms = 1;
	MOVLW      1
	MOVWF      _g_tick_100ms+0
;Interrupt_Manager.c,28 :: 		}
L_interrupt0:
;Interrupt_Manager.c,31 :: 		if (GET_BIT(PIR1, RCIF)) {
	MOVLW      5
	MOVWF      R0+0
	MOVF       12, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__interrupt10:
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt11
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__interrupt10
L__interrupt11:
	BTFSS      R1+0, 0
	GOTO       L_interrupt1
;Interrupt_Manager.c,32 :: 		u8 b = RCREG; /* Read the byte (auto-clears flag) */
	MOVF       26, 0
	MOVWF      R2+0
;Interrupt_Manager.c,35 :: 		if(g_frame_idx == 0u) {
	MOVF       _g_frame_idx+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt2
;Interrupt_Manager.c,36 :: 		if(b == UART_START_APP) {
	MOVF       R2+0, 0
	XORLW      204
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
;Interrupt_Manager.c,37 :: 		g_frame[0] = b;
	MOVF       R2+0, 0
	MOVWF      _g_frame+0
;Interrupt_Manager.c,38 :: 		g_frame_idx = 1u;
	MOVLW      1
	MOVWF      _g_frame_idx+0
;Interrupt_Manager.c,39 :: 		}
L_interrupt3:
;Interrupt_Manager.c,40 :: 		}
	GOTO       L_interrupt4
L_interrupt2:
;Interrupt_Manager.c,41 :: 		else if(g_frame_idx < 3u) {
	MOVLW      3
	SUBWF      _g_frame_idx+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt5
;Interrupt_Manager.c,42 :: 		g_frame[g_frame_idx++] = b;
	MOVF       _g_frame_idx+0, 0
	ADDLW      _g_frame+0
	MOVWF      FSR
	MOVF       R2+0, 0
	MOVWF      INDF+0
	INCF       _g_frame_idx+0, 1
;Interrupt_Manager.c,43 :: 		}
	GOTO       L_interrupt6
L_interrupt5:
;Interrupt_Manager.c,45 :: 		g_frame[3] = b;
	MOVF       R2+0, 0
	MOVWF      _g_frame+3
;Interrupt_Manager.c,46 :: 		g_frame_idx = 0u;
	CLRF       _g_frame_idx+0
;Interrupt_Manager.c,47 :: 		if(b == UART_END_APP) {
	MOVF       R2+0, 0
	XORLW      221
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt7
;Interrupt_Manager.c,48 :: 		g_frame_ready = 1u;
	MOVLW      1
	MOVWF      _g_frame_ready+0
;Interrupt_Manager.c,49 :: 		}
L_interrupt7:
;Interrupt_Manager.c,50 :: 		}
L_interrupt6:
L_interrupt4:
;Interrupt_Manager.c,51 :: 		}
L_interrupt1:
;Interrupt_Manager.c,52 :: 		}
L_end_interrupt:
L__interrupt9:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

Interrupt_Manager____?ag:

L_end_Interrupt_Manager___?ag:
	RETURN
; end of Interrupt_Manager____?ag
