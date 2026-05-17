
_Temp_Init:

;Temp.c,11 :: 		void Temp_Init(void)
;Temp.c,14 :: 		}
L_end_Temp_Init:
	RETURN
; end of _Temp_Init

_Temp_Read_C:

;Temp.c,16 :: 		s16 Temp_Read_C(void)
;Temp.c,18 :: 		u16 raw = 0;
;Temp.c,19 :: 		s16 temp_c = 0;
;Temp.c,21 :: 		raw = ADC_ReadAverage(TEMP_ADC_CHANNEL, TEMP_SAMPLES);
	MOVLW      1
	MOVWF      FARG_ADC_ReadAverage_channel+0
	MOVLW      4
	MOVWF      FARG_ADC_ReadAverage_samples+0
	CALL       _ADC_ReadAverage+0
;Temp.c,24 :: 		temp_c = (s16)(((u32)raw * 500u) / TEMP_ADC_RESOLUTION);
	MOVLW      0
	MOVWF      R0+1
	MOVWF      R0+2
	MOVWF      R0+3
	MOVLW      244
	MOVWF      R4+0
	MOVLW      1
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      10
	MOVWF      R8+0
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	MOVF       R0+2, 0
	MOVWF      R4+2
	MOVF       R0+3, 0
	MOVWF      R4+3
	MOVF       R8+0, 0
L__Temp_Read_C2:
	BTFSC      STATUS+0, 2
	GOTO       L__Temp_Read_C3
	RRF        R4+3, 1
	RRF        R4+2, 1
	RRF        R4+1, 1
	RRF        R4+0, 1
	BCF        R4+3, 7
	ADDLW      255
	GOTO       L__Temp_Read_C2
L__Temp_Read_C3:
;Temp.c,26 :: 		return temp_c;
	MOVF       R4+0, 0
	MOVWF      R0+0
;Temp.c,27 :: 		}
L_end_Temp_Read_C:
	RETURN
; end of _Temp_Read_C
