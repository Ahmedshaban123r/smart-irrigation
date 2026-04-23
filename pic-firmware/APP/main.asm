
main_UART_SendShort_Const:

;main.c,49 :: 		static void UART_SendShort_Const(const char *s)
;main.c,51 :: 		while(*s)
L_main_UART_SendShort_Const0:
	MOVF       FARG_main_UART_SendShort_Const_s+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       FARG_main_UART_SendShort_Const_s+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main_UART_SendShort_Const1
;main.c,53 :: 		UART_Write(*s++);
	MOVF       FARG_main_UART_SendShort_Const_s+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       FARG_main_UART_SendShort_Const_s+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      FARG_UART_Write_Data+0
	CALL       _UART_Write+0
	INCF       FARG_main_UART_SendShort_Const_s+0, 1
	BTFSC      STATUS+0, 2
	INCF       FARG_main_UART_SendShort_Const_s+1, 1
;main.c,54 :: 		}
	GOTO       L_main_UART_SendShort_Const0
L_main_UART_SendShort_Const1:
;main.c,55 :: 		}
L_end_UART_SendShort_Const:
	RETURN
; end of main_UART_SendShort_Const

main_Process_Cmd:

;main.c,58 :: 		static void Process_Cmd(void)
;main.c,60 :: 		u8 cmd = g_frame[1];
	MOVF       _g_frame+1, 0
	MOVWF      main_Process_Cmd_cmd_L0+0
;main.c,63 :: 		if(crc != (u8)(g_frame[0] ^ cmd))
	MOVF       _g_frame+1, 0
	XORWF      _g_frame+0, 0
	MOVWF      R1+0
	MOVF       _g_frame+2, 0
	XORWF      R1+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main_Process_Cmd2
;main.c,65 :: 		UART_SendShort_Const("NC\r\n");
	MOVLW      ?lstr_1_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_1_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
;main.c,66 :: 		return;
	GOTO       L_end_Process_Cmd
;main.c,67 :: 		}
L_main_Process_Cmd2:
;main.c,69 :: 		if(cmd == CMD_PUMP_ON)
	MOVF       main_Process_Cmd_cmd_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main_Process_Cmd3
;main.c,71 :: 		if(Safety_IsLocked())
	CALL       _Safety_IsLocked+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main_Process_Cmd4
;main.c,72 :: 		UART_SendShort_Const("NL\r\n");
	MOVLW      ?lstr_2_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_2_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
	GOTO       L_main_Process_Cmd5
L_main_Process_Cmd4:
;main.c,75 :: 		Relay_On();
	CALL       _Relay_On+0
;main.c,76 :: 		UART_SendShort_Const("AP\r\n");
	MOVLW      ?lstr_3_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_3_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
;main.c,77 :: 		}
L_main_Process_Cmd5:
;main.c,78 :: 		}
	GOTO       L_main_Process_Cmd6
L_main_Process_Cmd3:
;main.c,79 :: 		else if(cmd == CMD_PUMP_OFF)
	MOVF       main_Process_Cmd_cmd_L0+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_main_Process_Cmd7
;main.c,81 :: 		Relay_Off();
	CALL       _Relay_Off+0
;main.c,82 :: 		UART_SendShort_Const("AF\r\n");
	MOVLW      ?lstr_4_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_4_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
;main.c,83 :: 		}
	GOTO       L_main_Process_Cmd8
L_main_Process_Cmd7:
;main.c,84 :: 		else if(cmd == CMD_MANUAL_RESET)
	MOVF       main_Process_Cmd_cmd_L0+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_main_Process_Cmd9
;main.c,86 :: 		Safety_ManualReset();
	CALL       _Safety_ManualReset+0
;main.c,87 :: 		UART_SendShort_Const("AR\r\n");
	MOVLW      ?lstr_5_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_5_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
;main.c,88 :: 		}
	GOTO       L_main_Process_Cmd10
L_main_Process_Cmd9:
;main.c,91 :: 		UART_SendShort_Const("NU\r\n");
	MOVLW      ?lstr_6_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_6_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
;main.c,92 :: 		}
L_main_Process_Cmd10:
L_main_Process_Cmd8:
L_main_Process_Cmd6:
;main.c,93 :: 		}
L_end_Process_Cmd:
	RETURN
; end of main_Process_Cmd

main_LCD_ShowData:

;main.c,96 :: 		static void LCD_ShowData(void)
;main.c,99 :: 		LCD_GoToRowCol(1,1);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;main.c,100 :: 		LCD_SendString_Const("T:");
	MOVLW      ?lstr_7_main+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_7_main+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;main.c,101 :: 		LCD_SendNumber(g_temp_c);
	MOVF       _g_temp_c+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;main.c,102 :: 		LCD_SendString_Const("C H:");
	MOVLW      ?lstr_8_main+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_8_main+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;main.c,103 :: 		if(g_humidity_pct != 0xFF)
	MOVF       _g_humidity_pct+0, 0
	XORLW      255
	BTFSC      STATUS+0, 2
	GOTO       L_main_LCD_ShowData11
;main.c,105 :: 		LCD_SendNumber(g_humidity_pct);
	MOVF       _g_humidity_pct+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;main.c,106 :: 		LCD_SendString_Const("%   ");
	MOVLW      ?lstr_9_main+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_9_main+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;main.c,107 :: 		}
	GOTO       L_main_LCD_ShowData12
L_main_LCD_ShowData11:
;main.c,110 :: 		LCD_SendString_Const("--% ");
	MOVLW      ?lstr_10_main+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_10_main+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;main.c,111 :: 		}
L_main_LCD_ShowData12:
;main.c,114 :: 		LCD_GoToRowCol(2,1);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;main.c,115 :: 		LCD_SendString_Const("S:");
	MOVLW      ?lstr_11_main+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_11_main+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;main.c,116 :: 		LCD_SendNumber(g_soil_pct);
	MOVF       _g_soil_pct+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;main.c,117 :: 		LCD_SendString_Const("%         ");
	MOVLW      ?lstr_12_main+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_12_main+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;main.c,118 :: 		}
L_end_LCD_ShowData:
	RETURN
; end of main_LCD_ShowData

main_System_Init:

;main.c,121 :: 		static void System_Init(void)
;main.c,123 :: 		Sensors_Init();
	CALL       _Sensors_Init+0
;main.c,124 :: 		LCD_Init();
	CALL       _LCD_Init+0
;main.c,125 :: 		Relay_Init();
	CALL       _Relay_Init+0
;main.c,126 :: 		Buzzer_Init();
	CALL       _Buzzer_Init+0
;main.c,127 :: 		Safety_Init();
	CALL       _Safety_Init+0
;main.c,129 :: 		UART_TX_Init();
	CALL       _UART_TX_Init+0
;main.c,130 :: 		UART_RX_Init();
	CALL       _UART_RX_Init+0
;main.c,132 :: 		TMR0_Init();
	CALL       _TMR0_Init+0
;main.c,133 :: 		TMR0_SetInterval_ms(100);
	MOVLW      100
	MOVWF      FARG_TMR0_SetInterval_ms_milliseconds+0
	CALL       _TMR0_SetInterval_ms+0
;main.c,134 :: 		TMR0_Enable();
	CALL       _TMR0_Enable+0
;main.c,136 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;main.c,137 :: 		UART_SendShort_Const("RDY\r\n");
	MOVLW      ?lstr_13_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_13_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
;main.c,138 :: 		}
L_end_System_Init:
	RETURN
; end of main_System_Init

_main:

;main.c,141 :: 		void main(void)
;main.c,143 :: 		System_Init();
	CALL       main_System_Init+0
;main.c,145 :: 		while(1)
L_main13:
;main.c,147 :: 		if(g_tick_100ms)
	MOVF       _g_tick_100ms+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main15
;main.c,149 :: 		g_tick_100ms = 0;
	CLRF       _g_tick_100ms+0
;main.c,151 :: 		Safety_Run();
	CALL       _Safety_Run+0
;main.c,153 :: 		g_lcd_tick++;
	INCF       _g_lcd_tick+0, 1
;main.c,154 :: 		if(g_lcd_tick >= 5)
	MOVLW      5
	SUBWF      _g_lcd_tick+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main16
;main.c,156 :: 		g_lcd_tick = 0;
	CLRF       _g_lcd_tick+0
;main.c,158 :: 		g_temp_c       = Sensors_ReadTemperature_C();
	CALL       _Sensors_ReadTemperature_C+0
	MOVF       R0+0, 0
	MOVWF      _g_temp_c+0
;main.c,159 :: 		g_soil_pct     = Sensors_ReadSoilMoisture_Pct();
	CALL       _Sensors_ReadSoilMoisture_Pct+0
	MOVF       R0+0, 0
	MOVWF      _g_soil_pct+0
;main.c,160 :: 		g_humidity_pct = Sensors_ReadHumidity_Pct();
	CALL       _Sensors_ReadHumidity_Pct+0
	MOVF       R0+0, 0
	MOVWF      _g_humidity_pct+0
;main.c,163 :: 		if(Safety_GetState() == SAFETY_STATE_NORMAL)
	CALL       _Safety_GetState+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main17
;main.c,165 :: 		LCD_ShowData();
	CALL       main_LCD_ShowData+0
;main.c,166 :: 		}
L_main17:
;main.c,168 :: 		UART_SendShort_Const("RDY\r\n");
	MOVLW      ?lstr_14_main+0
	MOVWF      FARG_main_UART_SendShort_Const_s+0
	MOVLW      hi_addr(?lstr_14_main+0)
	MOVWF      FARG_main_UART_SendShort_Const_s+1
	CALL       main_UART_SendShort_Const+0
;main.c,169 :: 		}
L_main16:
;main.c,170 :: 		}
L_main15:
;main.c,172 :: 		if(g_frame_ready)
	MOVF       _g_frame_ready+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main18
;main.c,174 :: 		g_frame_ready = 0;
	CLRF       _g_frame_ready+0
;main.c,175 :: 		Process_Cmd();
	CALL       main_Process_Cmd+0
;main.c,176 :: 		}
L_main18:
;main.c,177 :: 		}
	GOTO       L_main13
;main.c,178 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
