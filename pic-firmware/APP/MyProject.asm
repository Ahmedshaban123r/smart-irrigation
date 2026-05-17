
_main:

;MyProject.c,30 :: 		void main(void)
;MyProject.c,32 :: 		u8  humidity    = 0;
	CLRF       main_humidity_L0+0
	CLRF       main_temperature_L0+0
	CLRF       main_soil_pct_L0+0
	CLRF       main_current_mA_L0+0
	CLRF       main_dht_status_L0+0
	CLRF       main_page_L0+0
;MyProject.c,40 :: 		Delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main0:
	DECFSZ     R13+0, 1
	GOTO       L_main0
	DECFSZ     R12+0, 1
	GOTO       L_main0
	DECFSZ     R11+0, 1
	GOTO       L_main0
	NOP
;MyProject.c,42 :: 		ADC_Init();
	CALL       _ADC_Init+0
;MyProject.c,43 :: 		LCD_Init();
	CALL       _LCD_Init+0
;MyProject.c,44 :: 		Humidity_Init();
	CALL       _Humidity_Init+0
;MyProject.c,45 :: 		Soil_Init();
	CALL       _Soil_Init+0
;MyProject.c,46 :: 		Current_Init();
	CALL       _Current_Init+0
;MyProject.c,49 :: 		LCD_GoToRowCol(LCD_ROW_1, 1);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;MyProject.c,50 :: 		LCD_SendString_Const(" Sensor Test    ");
	MOVLW      ?lstr_1_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_1_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,51 :: 		LCD_GoToRowCol(LCD_ROW_2, 1);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;MyProject.c,52 :: 		LCD_SendString_Const(" Initializing...");
	MOVLW      ?lstr_2_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_2_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,53 :: 		Delay_ms(1500);
	MOVLW      16
	MOVWF      R11+0
	MOVLW      57
	MOVWF      R12+0
	MOVLW      13
	MOVWF      R13+0
L_main1:
	DECFSZ     R13+0, 1
	GOTO       L_main1
	DECFSZ     R12+0, 1
	GOTO       L_main1
	DECFSZ     R11+0, 1
	GOTO       L_main1
	NOP
	NOP
;MyProject.c,54 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;MyProject.c,56 :: 		while(1)
L_main2:
;MyProject.c,59 :: 		dht_status  = Humidity_Read(&humidity, &temperature);
	MOVLW      main_humidity_L0+0
	MOVWF      FARG_Humidity_Read_humidity+0
	MOVLW      main_temperature_L0+0
	MOVWF      FARG_Humidity_Read_temperature+0
	CALL       _Humidity_Read+0
	MOVF       R0+0, 0
	MOVWF      main_dht_status_L0+0
;MyProject.c,60 :: 		soil_pct    = Soil_Read_Pct();
	CALL       _Soil_Read_Pct+0
	MOVF       R0+0, 0
	MOVWF      main_soil_pct_L0+0
;MyProject.c,61 :: 		current_mA  = Current_Read_mA();
	CALL       _Current_Read_mA+0
	MOVF       R0+0, 0
	MOVWF      main_current_mA_L0+0
;MyProject.c,63 :: 		if(page == 0)
	MOVF       main_page_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main4
;MyProject.c,66 :: 		LCD_GoToRowCol(LCD_ROW_1, 1);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;MyProject.c,67 :: 		if(dht_status == HUMIDITY_OK)
	MOVF       main_dht_status_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main5
;MyProject.c,69 :: 		LCD_SendString_Const("Hum : ");
	MOVLW      ?lstr_3_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_3_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,70 :: 		LCD_SendNumber((s16)humidity);
	MOVF       main_humidity_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;MyProject.c,71 :: 		LCD_SendString_Const(" %      ");
	MOVLW      ?lstr_4_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_4_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,72 :: 		}
	GOTO       L_main6
L_main5:
;MyProject.c,75 :: 		LCD_SendString_Const("DHT11 Error:    ");
	MOVLW      ?lstr_5_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_5_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,76 :: 		LCD_GoToRowCol(LCD_ROW_2, 1);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;MyProject.c,77 :: 		LCD_SendString_Const("Code: ");
	MOVLW      ?lstr_6_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_6_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,78 :: 		LCD_SendNumber((s16)dht_status);
	MOVF       main_dht_status_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;MyProject.c,79 :: 		LCD_SendString_Const("          ");
	MOVLW      ?lstr_7_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_7_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,80 :: 		}
L_main6:
;MyProject.c,82 :: 		if(dht_status == HUMIDITY_OK)
	MOVF       main_dht_status_L0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main7
;MyProject.c,84 :: 		LCD_GoToRowCol(LCD_ROW_2, 1);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;MyProject.c,85 :: 		LCD_SendString_Const("Temp: ");
	MOVLW      ?lstr_8_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_8_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,86 :: 		LCD_SendNumber((s16)temperature);
	MOVF       main_temperature_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;MyProject.c,87 :: 		LCD_SendString_Const(" C      ");
	MOVLW      ?lstr_9_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_9_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,88 :: 		}
L_main7:
;MyProject.c,89 :: 		}
	GOTO       L_main8
L_main4:
;MyProject.c,93 :: 		LCD_GoToRowCol(LCD_ROW_1, 1);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;MyProject.c,94 :: 		LCD_SendString_Const("Soil: ");
	MOVLW      ?lstr_10_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_10_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,95 :: 		LCD_SendNumber((s16)soil_pct);
	MOVF       main_soil_pct_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;MyProject.c,96 :: 		LCD_SendString_Const(" %      ");
	MOVLW      ?lstr_11_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_11_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,98 :: 		LCD_GoToRowCol(LCD_ROW_2, 1);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;MyProject.c,99 :: 		LCD_SendString_Const("Curr: ");
	MOVLW      ?lstr_12_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_12_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,100 :: 		LCD_SendNumber(current_mA);
	MOVF       main_current_mA_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;MyProject.c,101 :: 		LCD_SendString_Const(" mA  ");
	MOVLW      ?lstr_13_MyProject+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_13_MyProject+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;MyProject.c,102 :: 		}
L_main8:
;MyProject.c,104 :: 		page ^= 1u;   /* toggle between page 0 and 1 */
	MOVLW      1
	XORWF      main_page_L0+0, 1
;MyProject.c,106 :: 		Delay_ms(2000);
	MOVLW      21
	MOVWF      R11+0
	MOVLW      75
	MOVWF      R12+0
	MOVLW      190
	MOVWF      R13+0
L_main9:
	DECFSZ     R13+0, 1
	GOTO       L_main9
	DECFSZ     R12+0, 1
	GOTO       L_main9
	DECFSZ     R11+0, 1
	GOTO       L_main9
	NOP
;MyProject.c,107 :: 		}
	GOTO       L_main2
;MyProject.c,108 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
