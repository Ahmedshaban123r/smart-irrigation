
_Current_Init:

;Current.c,11 :: 		void Current_Init(void)
;Current.c,14 :: 		}
L_end_Current_Init:
	RETURN
; end of _Current_Init

_Current_Read_mA:

;Current.c,16 :: 		s16 Current_Read_mA(void)
;Current.c,18 :: 		u16 raw     = 0;
;Current.c,19 :: 		u32 vout_mv = 0;
;Current.c,20 :: 		s32 vdelta  = 0;
;Current.c,21 :: 		s16 current = 0;
;Current.c,23 :: 		raw = ADC_ReadAverage(CURRENT_ADC_CHANNEL, CURRENT_SAMPLES);
	MOVLW      2
	MOVWF      FARG_ADC_ReadAverage_channel+0
	MOVLW      8
	MOVWF      FARG_ADC_ReadAverage_samples+0
	CALL       _ADC_ReadAverage+0
;Current.c,25 :: 		vout_mv = ((u32)raw * CURRENT_VCC_MV) / CURRENT_ADC_RESOLUTION;
	MOVLW      0
	MOVWF      R0+1
	MOVWF      R0+2
	MOVWF      R0+3
	MOVLW      136
	MOVWF      R4+0
	MOVLW      19
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      10
	MOVWF      R4+0
	MOVF       R0+0, 0
	MOVWF      R8+0
	MOVF       R0+1, 0
	MOVWF      R8+1
	MOVF       R0+2, 0
	MOVWF      R8+2
	MOVF       R0+3, 0
	MOVWF      R8+3
	MOVF       R4+0, 0
L__Current_Read_mA2:
	BTFSC      STATUS+0, 2
	GOTO       L__Current_Read_mA3
	RRF        R8+3, 1
	RRF        R8+2, 1
	RRF        R8+1, 1
	RRF        R8+0, 1
	BCF        R8+3, 7
	ADDLW      255
	GOTO       L__Current_Read_mA2
L__Current_Read_mA3:
;Current.c,26 :: 		vdelta = (s32)vout_mv - (s32)CURRENT_OFFSET_MV;
	MOVLW      196
	MOVWF      R4+0
	MOVLW      9
	MOVWF      R4+1
	MOVLW      0
	MOVWF      R4+2
	MOVLW      0
	MOVWF      R4+3
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVF       R8+2, 0
	MOVWF      R0+2
	MOVF       R8+3, 0
	MOVWF      R0+3
	MOVF       R4+0, 0
	SUBWF      R0+0, 1
	MOVF       R4+1, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R4+1, 0
	SUBWF      R0+1, 1
	MOVF       R4+2, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R4+2, 0
	SUBWF      R0+2, 1
	MOVF       R4+3, 0
	BTFSS      STATUS+0, 0
	INCFSZ     R4+3, 0
	SUBWF      R0+3, 1
;Current.c,28 :: 		current = (s16)((vdelta * 1000) / (s32)CURRENT_SENS_MV_A);
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      66
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      0
	MOVWF      R4+2
	MOVLW      0
	MOVWF      R4+3
	CALL       _Div_32x32_S+0
;Current.c,30 :: 		return current;
;Current.c,31 :: 		}
L_end_Current_Read_mA:
	RETURN
; end of _Current_Read_mA
