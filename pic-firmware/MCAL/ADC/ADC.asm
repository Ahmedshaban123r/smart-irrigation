
_ADC_Init:

;ADC.c,16 :: 		void ADC_Init(void)
;ADC.c,19 :: 		SET_BIT(TRISA, ADC_CH_AN0);
	BSF        133, 0
;ADC.c,20 :: 		SET_BIT(TRISA, ADC_CH_AN1);
	BSF        133, 1
;ADC.c,21 :: 		SET_BIT(TRISA, ADC_CH_AN2);
	BSF        133, 2
;ADC.c,24 :: 		ADCON1 = ADC_ADCON1_CONFIG;
	MOVLW      128
	MOVWF      159
;ADC.c,27 :: 		ADCON0 &= 0b00111111;              /* Clear ADCS bits */
	MOVLW      63
	ANDWF      31, 1
;ADC.c,28 :: 		ADCON0 |= (ADC_CLK_FOSC_32 << 6);  /* Set ADC clock   */
	BSF        31, 7
;ADC.c,29 :: 		SET_BIT(ADCON0, ADON);             /* Power ON ADC    */
	BSF        31, 0
;ADC.c,32 :: 		Delay_us(ADC_ACQ_DELAY_US);
	MOVLW      16
	MOVWF      R13+0
L_ADC_Init0:
	DECFSZ     R13+0, 1
	GOTO       L_ADC_Init0
	NOP
;ADC.c,33 :: 		}
L_end_ADC_Init:
	RETURN
; end of _ADC_Init

_ADC_Read:

;ADC.c,35 :: 		u16 ADC_Read(u8 channel)
;ADC.c,37 :: 		u16 result = 0;
;ADC.c,40 :: 		ADCON0 &= 0b11000111;
	MOVLW      199
	ANDWF      31, 1
;ADC.c,41 :: 		ADCON0 |= (u8)((channel & 0x07) << 3);
	MOVLW      7
	ANDWF      FARG_ADC_Read_channel+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      31, 1
;ADC.c,44 :: 		Delay_us(ADC_ACQ_DELAY_US);
	MOVLW      16
	MOVWF      R13+0
L_ADC_Read1:
	DECFSZ     R13+0, 1
	GOTO       L_ADC_Read1
	NOP
;ADC.c,47 :: 		SET_BIT(ADCON0, GO_DONE);
	BSF        31, 2
;ADC.c,50 :: 		while(GET_BIT(ADCON0, GO_DONE));
L_ADC_Read2:
	MOVF       31, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSS      R1+0, 0
	GOTO       L_ADC_Read3
	GOTO       L_ADC_Read2
L_ADC_Read3:
;ADC.c,54 :: 		result |= (u16)ADRESL;
	MOVF       158, 0
	MOVWF      R0+0
;ADC.c,55 :: 		result &= 0x03FF;
	MOVLW      255
	ANDWF      R0+0, 1
;ADC.c,57 :: 		return result;
;ADC.c,58 :: 		}
L_end_ADC_Read:
	RETURN
; end of _ADC_Read

_ADC_ReadAverage:

;ADC.c,60 :: 		u16 ADC_ReadAverage(u8 channel, u8 samples)
;ADC.c,62 :: 		u32 sum = 0;
	CLRF       ADC_ReadAverage_sum_L0+0
	CLRF       ADC_ReadAverage_sum_L0+1
	CLRF       ADC_ReadAverage_sum_L0+2
	CLRF       ADC_ReadAverage_sum_L0+3
	CLRF       ADC_ReadAverage_i_L0+0
;ADC.c,65 :: 		if(samples == 0) return 0;
	MOVF       FARG_ADC_ReadAverage_samples+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_ADC_ReadAverage4
	CLRF       R0+0
	GOTO       L_end_ADC_ReadAverage
L_ADC_ReadAverage4:
;ADC.c,67 :: 		for(i = 0; i < samples; i++)
	CLRF       ADC_ReadAverage_i_L0+0
L_ADC_ReadAverage5:
	MOVF       FARG_ADC_ReadAverage_samples+0, 0
	SUBWF      ADC_ReadAverage_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_ADC_ReadAverage6
;ADC.c,69 :: 		sum += ADC_Read(channel);
	MOVF       FARG_ADC_ReadAverage_channel+0, 0
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVLW      0
	MOVWF      R0+1
	MOVWF      R0+2
	MOVWF      R0+3
	MOVF       ADC_ReadAverage_sum_L0+0, 0
	ADDWF      R0+0, 1
	MOVF       ADC_ReadAverage_sum_L0+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     ADC_ReadAverage_sum_L0+1, 0
	ADDWF      R0+1, 1
	MOVF       ADC_ReadAverage_sum_L0+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     ADC_ReadAverage_sum_L0+2, 0
	ADDWF      R0+2, 1
	MOVF       ADC_ReadAverage_sum_L0+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     ADC_ReadAverage_sum_L0+3, 0
	ADDWF      R0+3, 1
	MOVF       R0+0, 0
	MOVWF      ADC_ReadAverage_sum_L0+0
	MOVF       R0+1, 0
	MOVWF      ADC_ReadAverage_sum_L0+1
	MOVF       R0+2, 0
	MOVWF      ADC_ReadAverage_sum_L0+2
	MOVF       R0+3, 0
	MOVWF      ADC_ReadAverage_sum_L0+3
;ADC.c,67 :: 		for(i = 0; i < samples; i++)
	INCF       ADC_ReadAverage_i_L0+0, 1
;ADC.c,70 :: 		}
	GOTO       L_ADC_ReadAverage5
L_ADC_ReadAverage6:
;ADC.c,71 :: 		return (u16)(sum / samples);
	MOVF       FARG_ADC_ReadAverage_samples+0, 0
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	MOVF       ADC_ReadAverage_sum_L0+0, 0
	MOVWF      R0+0
	MOVF       ADC_ReadAverage_sum_L0+1, 0
	MOVWF      R0+1
	MOVF       ADC_ReadAverage_sum_L0+2, 0
	MOVWF      R0+2
	MOVF       ADC_ReadAverage_sum_L0+3, 0
	MOVWF      R0+3
	CALL       _Div_32x32_U+0
;ADC.c,72 :: 		}
L_end_ADC_ReadAverage:
	RETURN
; end of _ADC_ReadAverage
