
_Humidity_Init:

;Humidity.c,12 :: 		void Humidity_Init(void)
;Humidity.c,15 :: 		SET_BIT(HUMIDITY_DATA_TRIS, HUMIDITY_DATA_PIN);
	BSF        134, 0
;Humidity.c,16 :: 		}
L_end_Humidity_Init:
	RETURN
; end of _Humidity_Init

_Humidity_Read:

;Humidity.c,18 :: 		u8 Humidity_Read(u8 *humidity, s8 *temperature)
;Humidity.c,21 :: 		u8 dht_data[5] = {0, 0, 0, 0, 0};
	CLRF       Humidity_Read_dht_data_L0+0
	CLRF       Humidity_Read_dht_data_L0+1
	CLRF       Humidity_Read_dht_data_L0+2
	CLRF       Humidity_Read_dht_data_L0+3
	CLRF       Humidity_Read_dht_data_L0+4
	CLRF       Humidity_Read_i_L0+0
	CLRF       Humidity_Read_j_L0+0
	CLRF       Humidity_Read_timeout_L0+0
;Humidity.c,26 :: 		CLR_BIT(HUMIDITY_DATA_TRIS, HUMIDITY_DATA_PIN); /* Pin to Output */
	MOVLW      254
	ANDWF      134, 1
;Humidity.c,27 :: 		CLR_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN); /* Pull LOW */
	MOVLW      254
	ANDWF      6, 1
;Humidity.c,28 :: 		Delay_ms(18);                                   /* Min 18ms for DHT11 */
	MOVLW      47
	MOVWF      R12+0
	MOVLW      191
	MOVWF      R13+0
L_Humidity_Read0:
	DECFSZ     R13+0, 1
	GOTO       L_Humidity_Read0
	DECFSZ     R12+0, 1
	GOTO       L_Humidity_Read0
	NOP
	NOP
;Humidity.c,30 :: 		SET_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN); /* Release HIGH */
	BSF        6, 0
;Humidity.c,31 :: 		Delay_us(30);                                   /* Wait 20-40us */
	MOVLW      19
	MOVWF      R13+0
L_Humidity_Read1:
	DECFSZ     R13+0, 1
	GOTO       L_Humidity_Read1
	NOP
	NOP
;Humidity.c,33 :: 		SET_BIT(HUMIDITY_DATA_TRIS, HUMIDITY_DATA_PIN); /* Pin to Input */
	BSF        134, 0
;Humidity.c,37 :: 		timeout = 0;
	CLRF       Humidity_Read_timeout_L0+0
;Humidity.c,38 :: 		while(GET_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN))
L_Humidity_Read2:
	MOVF       6, 0
	MOVWF      R1+0
	BTFSS      R1+0, 0
	GOTO       L_Humidity_Read3
;Humidity.c,40 :: 		Delay_us(2);
	NOP
	NOP
	NOP
	NOP
;Humidity.c,41 :: 		if(++timeout > 50) return HUMIDITY_ERROR;
	INCF       Humidity_Read_timeout_L0+0, 1
	MOVF       Humidity_Read_timeout_L0+0, 0
	SUBLW      50
	BTFSC      STATUS+0, 0
	GOTO       L_Humidity_Read4
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_Humidity_Read
L_Humidity_Read4:
;Humidity.c,42 :: 		}
	GOTO       L_Humidity_Read2
L_Humidity_Read3:
;Humidity.c,45 :: 		timeout = 0;
	CLRF       Humidity_Read_timeout_L0+0
;Humidity.c,46 :: 		while(!GET_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN))
L_Humidity_Read5:
	MOVF       6, 0
	MOVWF      R1+0
	BTFSC      R1+0, 0
	GOTO       L_Humidity_Read6
;Humidity.c,48 :: 		Delay_us(2);
	NOP
	NOP
	NOP
	NOP
;Humidity.c,49 :: 		if(++timeout > 50) return HUMIDITY_ERROR;
	INCF       Humidity_Read_timeout_L0+0, 1
	MOVF       Humidity_Read_timeout_L0+0, 0
	SUBLW      50
	BTFSC      STATUS+0, 0
	GOTO       L_Humidity_Read7
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_Humidity_Read
L_Humidity_Read7:
;Humidity.c,50 :: 		}
	GOTO       L_Humidity_Read5
L_Humidity_Read6:
;Humidity.c,53 :: 		timeout = 0;
	CLRF       Humidity_Read_timeout_L0+0
;Humidity.c,54 :: 		while(GET_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN))
L_Humidity_Read8:
	MOVF       6, 0
	MOVWF      R1+0
	BTFSS      R1+0, 0
	GOTO       L_Humidity_Read9
;Humidity.c,56 :: 		Delay_us(2);
	NOP
	NOP
	NOP
	NOP
;Humidity.c,57 :: 		if(++timeout > 50) return HUMIDITY_ERROR;
	INCF       Humidity_Read_timeout_L0+0, 1
	MOVF       Humidity_Read_timeout_L0+0, 0
	SUBLW      50
	BTFSC      STATUS+0, 0
	GOTO       L_Humidity_Read10
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_Humidity_Read
L_Humidity_Read10:
;Humidity.c,58 :: 		}
	GOTO       L_Humidity_Read8
L_Humidity_Read9:
;Humidity.c,61 :: 		for(i = 0; i < 5; i++)
	CLRF       Humidity_Read_i_L0+0
L_Humidity_Read11:
	MOVLW      5
	SUBWF      Humidity_Read_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Humidity_Read12
;Humidity.c,63 :: 		for(j = 0; j < 8; j++)
	CLRF       Humidity_Read_j_L0+0
L_Humidity_Read14:
	MOVLW      8
	SUBWF      Humidity_Read_j_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Humidity_Read15
;Humidity.c,66 :: 		timeout = 0;
	CLRF       Humidity_Read_timeout_L0+0
;Humidity.c,67 :: 		while(!GET_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN))
L_Humidity_Read17:
	MOVF       6, 0
	MOVWF      R1+0
	BTFSC      R1+0, 0
	GOTO       L_Humidity_Read18
;Humidity.c,69 :: 		Delay_us(2);
	NOP
	NOP
	NOP
	NOP
;Humidity.c,70 :: 		if(++timeout > 50) return HUMIDITY_ERROR;
	INCF       Humidity_Read_timeout_L0+0, 1
	MOVF       Humidity_Read_timeout_L0+0, 0
	SUBLW      50
	BTFSC      STATUS+0, 0
	GOTO       L_Humidity_Read19
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_Humidity_Read
L_Humidity_Read19:
;Humidity.c,71 :: 		}
	GOTO       L_Humidity_Read17
L_Humidity_Read18:
;Humidity.c,78 :: 		Delay_us(35);
	MOVLW      23
	MOVWF      R13+0
L_Humidity_Read20:
	DECFSZ     R13+0, 1
	GOTO       L_Humidity_Read20
;Humidity.c,80 :: 		if(GET_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN))
	MOVF       6, 0
	MOVWF      R1+0
	BTFSS      R1+0, 0
	GOTO       L_Humidity_Read21
;Humidity.c,82 :: 		dht_data[i] |= (1 << (7 - j)); /* Set the bit */
	MOVF       Humidity_Read_i_L0+0, 0
	ADDLW      Humidity_Read_dht_data_L0+0
	MOVWF      R2+0
	MOVF       Humidity_Read_j_L0+0, 0
	SUBLW      7
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__Humidity_Read28:
	BTFSC      STATUS+0, 2
	GOTO       L__Humidity_Read29
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__Humidity_Read28
L__Humidity_Read29:
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Humidity.c,85 :: 		timeout = 0;
	CLRF       Humidity_Read_timeout_L0+0
;Humidity.c,86 :: 		while(GET_BIT(HUMIDITY_DATA_PORT, HUMIDITY_DATA_PIN))
L_Humidity_Read22:
	MOVF       6, 0
	MOVWF      R1+0
	BTFSS      R1+0, 0
	GOTO       L_Humidity_Read23
;Humidity.c,88 :: 		Delay_us(2);
	NOP
	NOP
	NOP
	NOP
;Humidity.c,89 :: 		if(++timeout > 50) return HUMIDITY_ERROR;
	INCF       Humidity_Read_timeout_L0+0, 1
	MOVF       Humidity_Read_timeout_L0+0, 0
	SUBLW      50
	BTFSC      STATUS+0, 0
	GOTO       L_Humidity_Read24
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_Humidity_Read
L_Humidity_Read24:
;Humidity.c,90 :: 		}
	GOTO       L_Humidity_Read22
L_Humidity_Read23:
;Humidity.c,91 :: 		}
L_Humidity_Read21:
;Humidity.c,63 :: 		for(j = 0; j < 8; j++)
	INCF       Humidity_Read_j_L0+0, 1
;Humidity.c,92 :: 		}
	GOTO       L_Humidity_Read14
L_Humidity_Read15:
;Humidity.c,61 :: 		for(i = 0; i < 5; i++)
	INCF       Humidity_Read_i_L0+0, 1
;Humidity.c,93 :: 		}
	GOTO       L_Humidity_Read11
L_Humidity_Read12:
;Humidity.c,96 :: 		if((u8)(dht_data[0] + dht_data[1] + dht_data[2] + dht_data[3]) != dht_data[4])
	MOVF       Humidity_Read_dht_data_L0+1, 0
	ADDWF      Humidity_Read_dht_data_L0+0, 0
	MOVWF      R0+0
	MOVF       Humidity_Read_dht_data_L0+2, 0
	ADDWF      R0+0, 1
	MOVF       Humidity_Read_dht_data_L0+3, 0
	ADDWF      R0+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORWF      Humidity_Read_dht_data_L0+4, 0
	BTFSC      STATUS+0, 2
	GOTO       L_Humidity_Read25
;Humidity.c,98 :: 		return HUMIDITY_ERROR;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_Humidity_Read
;Humidity.c,99 :: 		}
L_Humidity_Read25:
;Humidity.c,103 :: 		*humidity = dht_data[0];
	MOVF       FARG_Humidity_Read_humidity+0, 0
	MOVWF      FSR
	MOVF       Humidity_Read_dht_data_L0+0, 0
	MOVWF      INDF+0
;Humidity.c,104 :: 		*temperature = dht_data[2];
	MOVF       FARG_Humidity_Read_temperature+0, 0
	MOVWF      FSR
	MOVF       Humidity_Read_dht_data_L0+2, 0
	MOVWF      INDF+0
;Humidity.c,111 :: 		return HUMIDITY_OK;
	CLRF       R0+0
;Humidity.c,112 :: 		}
L_end_Humidity_Read:
	RETURN
; end of _Humidity_Read
