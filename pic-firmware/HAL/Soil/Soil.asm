
_Soil_Init:

;Soil.c,11 :: 		void Soil_Init(void)
;Soil.c,14 :: 		}
L_end_Soil_Init:
	RETURN
; end of _Soil_Init

_Soil_Read_Pct:

;Soil.c,16 :: 		u8 Soil_Read_Pct(void)
;Soil.c,18 :: 		u16 raw = ADC_ReadAverage(SOIL_ADC_CHANNEL, SOIL_SAMPLES);
	CLRF       FARG_ADC_ReadAverage_channel+0
	MOVLW      4
	MOVWF      FARG_ADC_ReadAverage_samples+0
	CALL       _ADC_ReadAverage+0
	MOVF       R0+0, 0
	MOVWF      Soil_Read_Pct_raw_L0+0
;Soil.c,19 :: 		u8  pct = 0;
;Soil.c,22 :: 		if(raw >= SOIL_DRY_ADC) return 0u;
	MOVLW      3
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Soil_Read_Pct4
	MOVLW      52
	SUBWF      Soil_Read_Pct_raw_L0+0, 0
L__Soil_Read_Pct4:
	BTFSS      STATUS+0, 0
	GOTO       L_Soil_Read_Pct0
	CLRF       R0+0
	GOTO       L_end_Soil_Read_Pct
L_Soil_Read_Pct0:
;Soil.c,23 :: 		if(raw <= SOIL_WET_ADC) return 100u;
	MOVLW      0
	SUBLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__Soil_Read_Pct5
	MOVF       Soil_Read_Pct_raw_L0+0, 0
	SUBLW      94
L__Soil_Read_Pct5:
	BTFSS      STATUS+0, 0
	GOTO       L_Soil_Read_Pct1
	MOVLW      100
	MOVWF      R0+0
	GOTO       L_end_Soil_Read_Pct
L_Soil_Read_Pct1:
;Soil.c,26 :: 		pct = (u8)(((u32)(SOIL_DRY_ADC - raw) * 100u) /
	MOVF       Soil_Read_Pct_raw_L0+0, 0
	SUBLW      52
	MOVWF      R0+0
	MOVLW      0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      3
	MOVWF      R0+1
	MOVLW      0
	MOVWF      R0+2
	MOVWF      R0+3
	MOVLW      100
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
;Soil.c,27 :: 		(SOIL_DRY_ADC - SOIL_WET_ADC));
	MOVLW      214
	MOVWF      R4+0
	MOVLW      1
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Div_32x32_U+0
;Soil.c,29 :: 		return pct;
;Soil.c,30 :: 		}
L_end_Soil_Read_Pct:
	RETURN
; end of _Soil_Read_Pct
