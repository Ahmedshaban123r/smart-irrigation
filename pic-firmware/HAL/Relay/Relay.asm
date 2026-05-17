
_Relay_Init:

;Relay.c,5 :: 		void Relay_Init(void)
;Relay.c,7 :: 		CLR_BIT(RELAY_TRIS, RELAY_PIN); /* Set as OUTPUT (0) */
	MOVLW      254
	ANDWF      136, 1
;Relay.c,8 :: 		CLR_BIT(RELAY_PORT, RELAY_PIN); /* Start INACTIVE (0) */
	MOVLW      254
	ANDWF      8, 1
;Relay.c,9 :: 		}
L_end_Relay_Init:
	RETURN
; end of _Relay_Init

_Relay_On:

;Relay.c,11 :: 		void Relay_On(void)
;Relay.c,13 :: 		SET_BIT(RELAY_PORT, RELAY_PIN);
	BSF        8, 0
;Relay.c,14 :: 		}
L_end_Relay_On:
	RETURN
; end of _Relay_On

_Relay_Off:

;Relay.c,16 :: 		void Relay_Off(void)
;Relay.c,18 :: 		CLR_BIT(RELAY_PORT, RELAY_PIN);
	MOVLW      254
	ANDWF      8, 1
;Relay.c,19 :: 		}
L_end_Relay_Off:
	RETURN
; end of _Relay_Off

_Relay_GetState:

;Relay.c,21 :: 		u8 Relay_GetState(void)
;Relay.c,23 :: 		return (u8)GET_BIT(RELAY_PORT, RELAY_PIN);
	MOVF       8, 0
	MOVWF      R0+0
	MOVLW      1
	ANDWF      R0+0, 1
;Relay.c,24 :: 		}
L_end_Relay_GetState:
	RETURN
; end of _Relay_GetState
