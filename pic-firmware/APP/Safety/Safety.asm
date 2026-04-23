
Safety_update_system_state:

;Safety.c,37 :: 		static void update_system_state(void)
;Safety.c,39 :: 		if(safety_fault_flags != SAFETY_FAULT_NONE)
	MOVF       Safety_safety_fault_flags+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_update_system_state0
;Safety.c,41 :: 		safety_state = SAFETY_STATE_FAULT;
	MOVLW      2
	MOVWF      Safety_safety_state+0
;Safety.c,42 :: 		}
	GOTO       L_Safety_update_system_state1
L_Safety_update_system_state0:
;Safety.c,43 :: 		else if(pump_locked_overwater || pump_locked_overcurr || pump_locked_overheat)
	MOVF       Safety_pump_locked_overwater+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_update_system_state56
	MOVF       Safety_pump_locked_overcurr+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_update_system_state56
	MOVF       Safety_pump_locked_overheat+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_update_system_state56
	GOTO       L_Safety_update_system_state4
L_Safety_update_system_state56:
;Safety.c,45 :: 		safety_state = SAFETY_STATE_WARNING;
	MOVLW      1
	MOVWF      Safety_safety_state+0
;Safety.c,46 :: 		}
	GOTO       L_Safety_update_system_state5
L_Safety_update_system_state4:
;Safety.c,49 :: 		safety_state = SAFETY_STATE_NORMAL;
	CLRF       Safety_safety_state+0
;Safety.c,50 :: 		}
L_Safety_update_system_state5:
L_Safety_update_system_state1:
;Safety.c,51 :: 		}
L_end_update_system_state:
	RETURN
; end of Safety_update_system_state

Safety_emergency_shutdown_all:

;Safety.c,53 :: 		static void emergency_shutdown_all(void)
;Safety.c,55 :: 		Relay_Off();
	CALL       _Relay_Off+0
;Safety.c,56 :: 		LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      6
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,57 :: 		LED_On(LED_RED_PORT, LED_RED_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_On_Port+0
	MOVLW      7
	MOVWF      FARG_LED_On_Pin+0
	CALL       _LED_On+0
;Safety.c,58 :: 		Buzzer_BeepN(3u, 500u, 200u);
	MOVLW      3
	MOVWF      FARG_Buzzer_BeepN_count+0
	MOVLW      244
	MOVWF      FARG_Buzzer_BeepN_ms_on+0
	MOVLW      200
	MOVWF      FARG_Buzzer_BeepN_ms_off+0
	CALL       _Buzzer_BeepN+0
;Safety.c,59 :: 		}
L_end_emergency_shutdown_all:
	RETURN
; end of Safety_emergency_shutdown_all

_Safety_Init:

;Safety.c,61 :: 		void Safety_Init(void)
;Safety.c,63 :: 		safety_state        = SAFETY_STATE_NORMAL;
	CLRF       Safety_safety_state+0
;Safety.c,64 :: 		safety_fault_flags  = SAFETY_FAULT_NONE;
	CLRF       Safety_safety_fault_flags+0
;Safety.c,65 :: 		overcurr_count      = 0u;
	CLRF       Safety_overcurr_count+0
;Safety.c,66 :: 		manual_reset_needed = 0u;
	CLRF       Safety_manual_reset_needed+0
;Safety.c,67 :: 		pump_locked_overwater = 0u;
	CLRF       Safety_pump_locked_overwater+0
;Safety.c,68 :: 		pump_locked_overcurr  = 0u;
	CLRF       Safety_pump_locked_overcurr+0
;Safety.c,69 :: 		pump_locked_overheat  = 0u;
	CLRF       Safety_pump_locked_overheat+0
;Safety.c,70 :: 		tick_soil  = 0u;
	CLRF       Safety_tick_soil+0
;Safety.c,71 :: 		tick_temp  = 0u;
	CLRF       Safety_tick_temp+0
;Safety.c,73 :: 		lcd_last_soil    = 0u;
	CLRF       Safety_lcd_last_soil+0
;Safety.c,74 :: 		lcd_last_current = 0u;
	CLRF       Safety_lcd_last_current+0
;Safety.c,75 :: 		lcd_last_temp    = 0u;
	CLRF       Safety_lcd_last_temp+0
;Safety.c,77 :: 		LED_Init(LED_YELLOW_TRIS, LED_YELLOW_PIN);
	MOVF       134, 0
	MOVWF      FARG_LED_Init_Port+0
	MOVLW      6
	MOVWF      FARG_LED_Init_Pin+0
	CALL       _LED_Init+0
;Safety.c,78 :: 		LED_Init(LED_RED_TRIS,    LED_RED_PIN);
	MOVF       134, 0
	MOVWF      FARG_LED_Init_Port+0
	MOVLW      7
	MOVWF      FARG_LED_Init_Pin+0
	CALL       _LED_Init+0
;Safety.c,79 :: 		LED_Off(LED_YELLOW_PORT,  LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      6
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,80 :: 		LED_Off(LED_RED_PORT,     LED_RED_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      7
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,81 :: 		}
L_end_Safety_Init:
	RETURN
; end of _Safety_Init

_Safety_CheckSoilMoisture:

;Safety.c,83 :: 		void Safety_CheckSoilMoisture(void)
;Safety.c,85 :: 		u8 soil_pct = Sensors_ReadSoilMoisture_Pct();
	CALL       _Sensors_ReadSoilMoisture_Pct+0
	MOVF       R0+0, 0
	MOVWF      Safety_CheckSoilMoisture_soil_pct_L0+0
;Safety.c,86 :: 		u8 new_state = 0u;
	CLRF       Safety_CheckSoilMoisture_new_state_L0+0
;Safety.c,88 :: 		if(soil_pct > SAFETY_SOIL_CRITICAL_PCT) new_state = 2u;
	MOVF       Safety_CheckSoilMoisture_soil_pct_L0+0, 0
	SUBLW      95
	BTFSC      STATUS+0, 0
	GOTO       L_Safety_CheckSoilMoisture6
	MOVLW      2
	MOVWF      Safety_CheckSoilMoisture_new_state_L0+0
	GOTO       L_Safety_CheckSoilMoisture7
L_Safety_CheckSoilMoisture6:
;Safety.c,89 :: 		else if(soil_pct > SAFETY_SOIL_WARN_PCT) new_state = 1u;
	MOVF       Safety_CheckSoilMoisture_soil_pct_L0+0, 0
	SUBLW      80
	BTFSC      STATUS+0, 0
	GOTO       L_Safety_CheckSoilMoisture8
	MOVLW      1
	MOVWF      Safety_CheckSoilMoisture_new_state_L0+0
	GOTO       L_Safety_CheckSoilMoisture9
L_Safety_CheckSoilMoisture8:
;Safety.c,90 :: 		else new_state = 0u;
	CLRF       Safety_CheckSoilMoisture_new_state_L0+0
L_Safety_CheckSoilMoisture9:
L_Safety_CheckSoilMoisture7:
;Safety.c,92 :: 		if(new_state == 2u)
	MOVF       Safety_CheckSoilMoisture_new_state_L0+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_CheckSoilMoisture10
;Safety.c,94 :: 		if(!manual_reset_needed)
	MOVF       Safety_manual_reset_needed+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_CheckSoilMoisture11
;Safety.c,96 :: 		Relay_Off();
	CALL       _Relay_Off+0
;Safety.c,97 :: 		pump_locked_overwater = 1u;
	MOVLW      1
	MOVWF      Safety_pump_locked_overwater+0
;Safety.c,98 :: 		safety_fault_flags |= SAFETY_FAULT_OVERWATER;
	BSF        Safety_safety_fault_flags+0, 0
;Safety.c,99 :: 		}
L_Safety_CheckSoilMoisture11:
;Safety.c,100 :: 		LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      6
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,101 :: 		LED_On(LED_RED_PORT, LED_RED_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_On_Port+0
	MOVLW      7
	MOVWF      FARG_LED_On_Pin+0
	CALL       _LED_On+0
;Safety.c,103 :: 		if(lcd_last_soil != 2u)
	MOVF       Safety_lcd_last_soil+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_CheckSoilMoisture12
;Safety.c,105 :: 		Buzzer_BeepN(2u, 300u, 100u);
	MOVLW      2
	MOVWF      FARG_Buzzer_BeepN_count+0
	MOVLW      44
	MOVWF      FARG_Buzzer_BeepN_ms_on+0
	MOVLW      100
	MOVWF      FARG_Buzzer_BeepN_ms_off+0
	CALL       _Buzzer_BeepN+0
;Safety.c,106 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,107 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,108 :: 		LCD_SendString_Const("! OVERWATER FALT");
	MOVLW      ?lstr_1_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_1_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,109 :: 		}
L_Safety_CheckSoilMoisture12:
;Safety.c,110 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,111 :: 		LCD_SendString_Const("Soil:");
	MOVLW      ?lstr_2_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_2_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,112 :: 		LCD_SendNumber((s16)soil_pct);
	MOVF       Safety_CheckSoilMoisture_soil_pct_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,113 :: 		LCD_SendString_Const("%        ");
	MOVLW      ?lstr_3_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_3_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,114 :: 		}
	GOTO       L_Safety_CheckSoilMoisture13
L_Safety_CheckSoilMoisture10:
;Safety.c,115 :: 		else if(soil_pct <= SAFETY_SOIL_RECOVERY_PCT && (safety_fault_flags & SAFETY_FAULT_OVERWATER))
	MOVF       Safety_CheckSoilMoisture_soil_pct_L0+0, 0
	SUBLW      65
	BTFSS      STATUS+0, 0
	GOTO       L_Safety_CheckSoilMoisture16
	BTFSS      Safety_safety_fault_flags+0, 0
	GOTO       L_Safety_CheckSoilMoisture16
L__Safety_CheckSoilMoisture57:
;Safety.c,117 :: 		safety_fault_flags   &= ~SAFETY_FAULT_OVERWATER;
	MOVLW      254
	ANDWF      Safety_safety_fault_flags+0, 1
;Safety.c,118 :: 		pump_locked_overwater  = 0u;
	CLRF       Safety_pump_locked_overwater+0
;Safety.c,119 :: 		new_state = 0u;
	CLRF       Safety_CheckSoilMoisture_new_state_L0+0
;Safety.c,121 :: 		LED_Off(LED_RED_PORT, LED_RED_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      7
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,122 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,123 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,124 :: 		LCD_SendString_Const("Soil Recovered  ");
	MOVLW      ?lstr_4_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_4_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,125 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,126 :: 		LCD_SendString_Const("Soil:");
	MOVLW      ?lstr_5_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_5_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,127 :: 		LCD_SendNumber((s16)soil_pct);
	MOVF       Safety_CheckSoilMoisture_soil_pct_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,128 :: 		LCD_SendString_Const("%        ");
	MOVLW      ?lstr_6_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_6_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,129 :: 		}
	GOTO       L_Safety_CheckSoilMoisture17
L_Safety_CheckSoilMoisture16:
;Safety.c,130 :: 		else if(new_state == 1u)
	MOVF       Safety_CheckSoilMoisture_new_state_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_CheckSoilMoisture18
;Safety.c,132 :: 		LED_On(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_On_Port+0
	MOVLW      6
	MOVWF      FARG_LED_On_Pin+0
	CALL       _LED_On+0
;Safety.c,133 :: 		if(lcd_last_soil != 1u)
	MOVF       Safety_lcd_last_soil+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_CheckSoilMoisture19
;Safety.c,135 :: 		Buzzer_Beep(100u);
	MOVLW      100
	MOVWF      FARG_Buzzer_Beep_duration_ms+0
	CALL       _Buzzer_Beep+0
;Safety.c,136 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,137 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,138 :: 		LCD_SendString_Const("SOIL SATURATED  ");
	MOVLW      ?lstr_7_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_7_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,139 :: 		}
L_Safety_CheckSoilMoisture19:
;Safety.c,140 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,141 :: 		LCD_SendString_Const("Soil:");
	MOVLW      ?lstr_8_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_8_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,142 :: 		LCD_SendNumber((s16)soil_pct);
	MOVF       Safety_CheckSoilMoisture_soil_pct_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,143 :: 		LCD_SendString_Const("%        ");
	MOVLW      ?lstr_9_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_9_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,144 :: 		}
	GOTO       L_Safety_CheckSoilMoisture20
L_Safety_CheckSoilMoisture18:
;Safety.c,147 :: 		if(!(safety_fault_flags & SAFETY_FAULT_OVERWATER))
	BTFSC      Safety_safety_fault_flags+0, 0
	GOTO       L_Safety_CheckSoilMoisture21
;Safety.c,149 :: 		pump_locked_overwater = 0u;
	CLRF       Safety_pump_locked_overwater+0
;Safety.c,150 :: 		LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      6
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,151 :: 		}
L_Safety_CheckSoilMoisture21:
;Safety.c,152 :: 		}
L_Safety_CheckSoilMoisture20:
L_Safety_CheckSoilMoisture17:
L_Safety_CheckSoilMoisture13:
;Safety.c,154 :: 		lcd_last_soil = new_state;
	MOVF       Safety_CheckSoilMoisture_new_state_L0+0, 0
	MOVWF      Safety_lcd_last_soil+0
;Safety.c,155 :: 		update_system_state();
	CALL       Safety_update_system_state+0
;Safety.c,156 :: 		}
L_end_Safety_CheckSoilMoisture:
	RETURN
; end of _Safety_CheckSoilMoisture

_Safety_CheckOvercurrent:

;Safety.c,158 :: 		void Safety_CheckOvercurrent(void)
;Safety.c,160 :: 		s16 current_ma = Sensors_ReadCurrent_mA();
	CALL       _Sensors_ReadCurrent_mA+0
	MOVF       R0+0, 0
	MOVWF      Safety_CheckOvercurrent_current_ma_L0+0
;Safety.c,161 :: 		u16 abs_ma = (current_ma < 0) ? (u16)(-current_ma) : (u16)current_ma;
	MOVLW      128
	XORWF      R0+0, 0
	MOVWF      R1+0
	MOVLW      128
	XORLW      0
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Safety_CheckOvercurrent22
	MOVF       Safety_CheckOvercurrent_current_ma_L0+0, 0
	SUBLW      0
	MOVWF      ?FLOC___Safety_CheckOvercurrentT43+0
	GOTO       L_Safety_CheckOvercurrent23
L_Safety_CheckOvercurrent22:
	MOVF       Safety_CheckOvercurrent_current_ma_L0+0, 0
	MOVWF      ?FLOC___Safety_CheckOvercurrentT43+0
L_Safety_CheckOvercurrent23:
	MOVF       ?FLOC___Safety_CheckOvercurrentT43+0, 0
	MOVWF      Safety_CheckOvercurrent_abs_ma_L0+0
;Safety.c,162 :: 		u8  new_state = 0u;
	CLRF       Safety_CheckOvercurrent_new_state_L0+0
;Safety.c,164 :: 		if(abs_ma > SAFETY_CURRENT_CRITICAL_MA)
	MOVLW      0
	SUBLW      2
	BTFSS      STATUS+0, 2
	GOTO       L__Safety_CheckOvercurrent65
	MOVF       Safety_CheckOvercurrent_abs_ma_L0+0, 0
	SUBLW      238
L__Safety_CheckOvercurrent65:
	BTFSC      STATUS+0, 0
	GOTO       L_Safety_CheckOvercurrent24
;Safety.c,166 :: 		new_state = 2u;
	MOVLW      2
	MOVWF      Safety_CheckOvercurrent_new_state_L0+0
;Safety.c,167 :: 		if(!manual_reset_needed)
	MOVF       Safety_manual_reset_needed+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_CheckOvercurrent25
;Safety.c,169 :: 		emergency_shutdown_all();
	CALL       Safety_emergency_shutdown_all+0
;Safety.c,170 :: 		pump_locked_overcurr  = 1u;
	MOVLW      1
	MOVWF      Safety_pump_locked_overcurr+0
;Safety.c,171 :: 		safety_fault_flags   |= SAFETY_FAULT_OVERCURR;
	BSF        Safety_safety_fault_flags+0, 1
;Safety.c,172 :: 		manual_reset_needed   = 1u;
	MOVLW      1
	MOVWF      Safety_manual_reset_needed+0
;Safety.c,173 :: 		overcurr_count        = 0u;
	CLRF       Safety_overcurr_count+0
;Safety.c,174 :: 		}
L_Safety_CheckOvercurrent25:
;Safety.c,176 :: 		if(lcd_last_current != 2u)
	MOVF       Safety_lcd_last_current+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_CheckOvercurrent26
;Safety.c,178 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,179 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,180 :: 		LCD_SendString_Const("! OVERCURR FAULT");
	MOVLW      ?lstr_10_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_10_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,181 :: 		}
L_Safety_CheckOvercurrent26:
;Safety.c,182 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,183 :: 		LCD_SendString_Const("I:");
	MOVLW      ?lstr_11_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_11_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,184 :: 		LCD_SendNumber((s16)abs_ma);
	MOVF       Safety_CheckOvercurrent_abs_ma_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,185 :: 		LCD_SendString_Const("mA LOCKED  ");
	MOVLW      ?lstr_12_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_12_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,186 :: 		}
	GOTO       L_Safety_CheckOvercurrent27
L_Safety_CheckOvercurrent24:
;Safety.c,187 :: 		else if(abs_ma > SAFETY_CURRENT_WARN_MA)
	MOVLW      0
	SUBLW      2
	BTFSS      STATUS+0, 2
	GOTO       L__Safety_CheckOvercurrent66
	MOVF       Safety_CheckOvercurrent_abs_ma_L0+0, 0
	SUBLW      88
L__Safety_CheckOvercurrent66:
	BTFSC      STATUS+0, 0
	GOTO       L_Safety_CheckOvercurrent28
;Safety.c,189 :: 		new_state = 1u;
	MOVLW      1
	MOVWF      Safety_CheckOvercurrent_new_state_L0+0
;Safety.c,190 :: 		overcurr_count++;
	INCF       Safety_overcurr_count+0, 1
;Safety.c,192 :: 		if(overcurr_count >= SAFETY_CURRENT_PERSIST_CNT)
	MOVLW      5
	SUBWF      Safety_overcurr_count+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_Safety_CheckOvercurrent29
;Safety.c,194 :: 		LED_On(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_On_Port+0
	MOVLW      6
	MOVWF      FARG_LED_On_Pin+0
	CALL       _LED_On+0
;Safety.c,195 :: 		if(lcd_last_current != 1u)
	MOVF       Safety_lcd_last_current+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_CheckOvercurrent30
;Safety.c,197 :: 		Buzzer_Beep(200u);
	MOVLW      200
	MOVWF      FARG_Buzzer_Beep_duration_ms+0
	CALL       _Buzzer_Beep+0
;Safety.c,198 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,199 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,200 :: 		LCD_SendString_Const("HIGH CURRENT!   ");
	MOVLW      ?lstr_13_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_13_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,201 :: 		}
L_Safety_CheckOvercurrent30:
;Safety.c,202 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,203 :: 		LCD_SendString_Const("I:");
	MOVLW      ?lstr_14_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_14_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,204 :: 		LCD_SendNumber((s16)abs_ma);
	MOVF       Safety_CheckOvercurrent_abs_ma_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,205 :: 		LCD_SendString_Const("mA     ");
	MOVLW      ?lstr_15_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_15_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,206 :: 		}
L_Safety_CheckOvercurrent29:
;Safety.c,207 :: 		}
	GOTO       L_Safety_CheckOvercurrent31
L_Safety_CheckOvercurrent28:
;Safety.c,210 :: 		new_state      = 0u;
	CLRF       Safety_CheckOvercurrent_new_state_L0+0
;Safety.c,211 :: 		overcurr_count = 0u;
	CLRF       Safety_overcurr_count+0
;Safety.c,212 :: 		if(!(safety_fault_flags & SAFETY_FAULT_OVERCURR))
	BTFSC      Safety_safety_fault_flags+0, 1
	GOTO       L_Safety_CheckOvercurrent32
;Safety.c,214 :: 		pump_locked_overcurr = 0u;
	CLRF       Safety_pump_locked_overcurr+0
;Safety.c,215 :: 		LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      6
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,216 :: 		}
L_Safety_CheckOvercurrent32:
;Safety.c,217 :: 		}
L_Safety_CheckOvercurrent31:
L_Safety_CheckOvercurrent27:
;Safety.c,219 :: 		lcd_last_current = new_state;
	MOVF       Safety_CheckOvercurrent_new_state_L0+0, 0
	MOVWF      Safety_lcd_last_current+0
;Safety.c,220 :: 		update_system_state();
	CALL       Safety_update_system_state+0
;Safety.c,221 :: 		}
L_end_Safety_CheckOvercurrent:
	RETURN
; end of _Safety_CheckOvercurrent

_Safety_CheckTemperature:

;Safety.c,223 :: 		void Safety_CheckTemperature(void)
;Safety.c,225 :: 		s16 temp_c = Sensors_ReadTemperature_C();
	CALL       _Sensors_ReadTemperature_C+0
	MOVF       R0+0, 0
	MOVWF      Safety_CheckTemperature_temp_c_L0+0
;Safety.c,226 :: 		u8  new_state = 0u;
	CLRF       Safety_CheckTemperature_new_state_L0+0
;Safety.c,228 :: 		if(temp_c > SAFETY_TEMP_CRITICAL_C) new_state = 2u;
	MOVLW      128
	XORLW      55
	MOVWF      R0+0
	MOVLW      128
	XORWF      Safety_CheckTemperature_temp_c_L0+0, 0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Safety_CheckTemperature33
	MOVLW      2
	MOVWF      Safety_CheckTemperature_new_state_L0+0
	GOTO       L_Safety_CheckTemperature34
L_Safety_CheckTemperature33:
;Safety.c,229 :: 		else if(temp_c > SAFETY_TEMP_WARN_C) new_state = 1u;
	MOVLW      128
	XORLW      45
	MOVWF      R0+0
	MOVLW      128
	XORWF      Safety_CheckTemperature_temp_c_L0+0, 0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Safety_CheckTemperature35
	MOVLW      1
	MOVWF      Safety_CheckTemperature_new_state_L0+0
	GOTO       L_Safety_CheckTemperature36
L_Safety_CheckTemperature35:
;Safety.c,230 :: 		else new_state = 0u;
	CLRF       Safety_CheckTemperature_new_state_L0+0
L_Safety_CheckTemperature36:
L_Safety_CheckTemperature34:
;Safety.c,232 :: 		if(new_state == 2u)
	MOVF       Safety_CheckTemperature_new_state_L0+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_CheckTemperature37
;Safety.c,234 :: 		if(!manual_reset_needed)
	MOVF       Safety_manual_reset_needed+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_CheckTemperature38
;Safety.c,236 :: 		emergency_shutdown_all();
	CALL       Safety_emergency_shutdown_all+0
;Safety.c,237 :: 		pump_locked_overheat = 1u;
	MOVLW      1
	MOVWF      Safety_pump_locked_overheat+0
;Safety.c,238 :: 		safety_fault_flags  |= SAFETY_FAULT_OVERHEAT;
	BSF        Safety_safety_fault_flags+0, 2
;Safety.c,239 :: 		}
L_Safety_CheckTemperature38:
;Safety.c,241 :: 		if(lcd_last_temp != 2u)
	MOVF       Safety_lcd_last_temp+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_CheckTemperature39
;Safety.c,243 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,244 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,245 :: 		LCD_SendString_Const("! OVERHEAT FAULT");
	MOVLW      ?lstr_16_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_16_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,246 :: 		}
L_Safety_CheckTemperature39:
;Safety.c,247 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,248 :: 		LCD_SendString_Const("T:");
	MOVLW      ?lstr_17_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_17_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,249 :: 		LCD_SendNumber((s16)temp_c);
	MOVF       Safety_CheckTemperature_temp_c_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,250 :: 		LCD_SendString_Const("C SHUTDOWN  ");
	MOVLW      ?lstr_18_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_18_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,251 :: 		}
	GOTO       L_Safety_CheckTemperature40
L_Safety_CheckTemperature37:
;Safety.c,252 :: 		else if(temp_c <= SAFETY_TEMP_RECOVERY_C && (safety_fault_flags & SAFETY_FAULT_OVERHEAT))
	MOVLW      128
	XORLW      40
	MOVWF      R0+0
	MOVLW      128
	XORWF      Safety_CheckTemperature_temp_c_L0+0, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_Safety_CheckTemperature43
	BTFSS      Safety_safety_fault_flags+0, 2
	GOTO       L_Safety_CheckTemperature43
L__Safety_CheckTemperature58:
;Safety.c,254 :: 		safety_fault_flags  &= ~SAFETY_FAULT_OVERHEAT;
	MOVLW      251
	ANDWF      Safety_safety_fault_flags+0, 1
;Safety.c,255 :: 		pump_locked_overheat = 0u;
	CLRF       Safety_pump_locked_overheat+0
;Safety.c,256 :: 		new_state = 0u;
	CLRF       Safety_CheckTemperature_new_state_L0+0
;Safety.c,258 :: 		LED_Off(LED_RED_PORT, LED_RED_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      7
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,259 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,260 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,261 :: 		LCD_SendString_Const("Temp Recovered  ");
	MOVLW      ?lstr_19_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_19_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,262 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,263 :: 		LCD_SendString_Const("T:");
	MOVLW      ?lstr_20_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_20_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,264 :: 		LCD_SendNumber((s16)temp_c);
	MOVF       Safety_CheckTemperature_temp_c_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,265 :: 		LCD_SendString_Const("C OK    ");
	MOVLW      ?lstr_21_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_21_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,266 :: 		}
	GOTO       L_Safety_CheckTemperature44
L_Safety_CheckTemperature43:
;Safety.c,267 :: 		else if(new_state == 1u)
	MOVF       Safety_CheckTemperature_new_state_L0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_Safety_CheckTemperature45
;Safety.c,269 :: 		LED_On(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_On_Port+0
	MOVLW      6
	MOVWF      FARG_LED_On_Pin+0
	CALL       _LED_On+0
;Safety.c,270 :: 		if(lcd_last_temp != 1u)
	MOVF       Safety_lcd_last_temp+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_CheckTemperature46
;Safety.c,272 :: 		Buzzer_Beep(150u);
	MOVLW      150
	MOVWF      FARG_Buzzer_Beep_duration_ms+0
	CALL       _Buzzer_Beep+0
;Safety.c,273 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,274 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,275 :: 		LCD_SendString_Const("HIGH TEMP WARN  ");
	MOVLW      ?lstr_22_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_22_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,276 :: 		}
L_Safety_CheckTemperature46:
;Safety.c,277 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,278 :: 		LCD_SendString_Const("T:");
	MOVLW      ?lstr_23_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_23_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,279 :: 		LCD_SendNumber((s16)temp_c);
	MOVF       Safety_CheckTemperature_temp_c_L0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
	CALL       _LCD_SendNumber+0
;Safety.c,280 :: 		LCD_SendString_Const("C       ");
	MOVLW      ?lstr_24_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_24_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,281 :: 		}
	GOTO       L_Safety_CheckTemperature47
L_Safety_CheckTemperature45:
;Safety.c,284 :: 		if(!(safety_fault_flags & SAFETY_FAULT_OVERHEAT))
	BTFSC      Safety_safety_fault_flags+0, 2
	GOTO       L_Safety_CheckTemperature48
;Safety.c,286 :: 		pump_locked_overheat = 0u;
	CLRF       Safety_pump_locked_overheat+0
;Safety.c,287 :: 		LED_Off(LED_YELLOW_PORT, LED_YELLOW_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      6
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,288 :: 		}
L_Safety_CheckTemperature48:
;Safety.c,289 :: 		}
L_Safety_CheckTemperature47:
L_Safety_CheckTemperature44:
L_Safety_CheckTemperature40:
;Safety.c,291 :: 		lcd_last_temp = new_state;
	MOVF       Safety_CheckTemperature_new_state_L0+0, 0
	MOVWF      Safety_lcd_last_temp+0
;Safety.c,292 :: 		update_system_state();
	CALL       Safety_update_system_state+0
;Safety.c,293 :: 		}
L_end_Safety_CheckTemperature:
	RETURN
; end of _Safety_CheckTemperature

_Safety_IsLocked:

;Safety.c,295 :: 		u8 Safety_IsLocked(void)
;Safety.c,297 :: 		return (pump_locked_overwater || pump_locked_overcurr || pump_locked_overheat) ? 1u : 0u;
	MOVF       Safety_pump_locked_overwater+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Safety_IsLocked59
	MOVF       Safety_pump_locked_overcurr+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Safety_IsLocked59
	MOVF       Safety_pump_locked_overheat+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Safety_IsLocked59
	GOTO       L_Safety_IsLocked51
L__Safety_IsLocked59:
	MOVLW      1
	MOVWF      R1+0
	GOTO       L_Safety_IsLocked52
L_Safety_IsLocked51:
	CLRF       R1+0
L_Safety_IsLocked52:
	MOVF       R1+0, 0
	MOVWF      R0+0
;Safety.c,298 :: 		}
L_end_Safety_IsLocked:
	RETURN
; end of _Safety_IsLocked

_Safety_GetFaultFlags:

;Safety.c,300 :: 		u8 Safety_GetFaultFlags(void) { return safety_fault_flags; }
	MOVF       Safety_safety_fault_flags+0, 0
	MOVWF      R0+0
L_end_Safety_GetFaultFlags:
	RETURN
; end of _Safety_GetFaultFlags

_Safety_GetState:

;Safety.c,301 :: 		u8 Safety_GetState(void) { return safety_state; }
	MOVF       Safety_safety_state+0, 0
	MOVWF      R0+0
L_end_Safety_GetState:
	RETURN
; end of _Safety_GetState

_Safety_ManualReset:

;Safety.c,303 :: 		void Safety_ManualReset(void)
;Safety.c,305 :: 		if(manual_reset_needed)
	MOVF       Safety_manual_reset_needed+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_Safety_ManualReset53
;Safety.c,307 :: 		manual_reset_needed  = 0u;
	CLRF       Safety_manual_reset_needed+0
;Safety.c,308 :: 		overcurr_count       = 0u;
	CLRF       Safety_overcurr_count+0
;Safety.c,309 :: 		pump_locked_overcurr = 0u;
	CLRF       Safety_pump_locked_overcurr+0
;Safety.c,310 :: 		safety_fault_flags  &= ~SAFETY_FAULT_OVERCURR;
	MOVLW      253
	ANDWF      Safety_safety_fault_flags+0, 1
;Safety.c,312 :: 		LED_Off(LED_RED_PORT, LED_RED_PIN);
	MOVF       6, 0
	MOVWF      FARG_LED_Off_Port+0
	MOVLW      7
	MOVWF      FARG_LED_Off_Pin+0
	CALL       _LED_Off+0
;Safety.c,314 :: 		LCD_Clear();
	CALL       _LCD_Clear+0
;Safety.c,315 :: 		LCD_GoToRowCol(1u, 1u);
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,316 :: 		LCD_SendString_Const("System Reset OK ");
	MOVLW      ?lstr_25_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_25_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,317 :: 		LCD_GoToRowCol(2u, 1u);
	MOVLW      2
	MOVWF      FARG_LCD_GoToRowCol_row+0
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
	CALL       _LCD_GoToRowCol+0
;Safety.c,318 :: 		LCD_SendString_Const("Monitor Active  ");
	MOVLW      ?lstr_26_Safety+0
	MOVWF      FARG_LCD_SendString_Const_str+0
	MOVLW      hi_addr(?lstr_26_Safety+0)
	MOVWF      FARG_LCD_SendString_Const_str+1
	CALL       _LCD_SendString_Const+0
;Safety.c,320 :: 		update_system_state();
	CALL       Safety_update_system_state+0
;Safety.c,321 :: 		}
L_Safety_ManualReset53:
;Safety.c,322 :: 		}
L_end_Safety_ManualReset:
	RETURN
; end of _Safety_ManualReset

_Safety_Run:

;Safety.c,324 :: 		void Safety_Run(void)
;Safety.c,326 :: 		Safety_CheckOvercurrent();
	CALL       _Safety_CheckOvercurrent+0
;Safety.c,328 :: 		tick_soil++;
	INCF       Safety_tick_soil+0, 1
;Safety.c,329 :: 		if(tick_soil >= 10u) { tick_soil = 0u; Safety_CheckSoilMoisture(); }
	MOVLW      10
	SUBWF      Safety_tick_soil+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_Safety_Run54
	CLRF       Safety_tick_soil+0
	CALL       _Safety_CheckSoilMoisture+0
L_Safety_Run54:
;Safety.c,331 :: 		tick_temp++;
	INCF       Safety_tick_temp+0, 1
;Safety.c,332 :: 		if(tick_temp >= 20u) { tick_temp = 0u; Safety_CheckTemperature(); }
	MOVLW      20
	SUBWF      Safety_tick_temp+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_Safety_Run55
	CLRF       Safety_tick_temp+0
	CALL       _Safety_CheckTemperature+0
L_Safety_Run55:
;Safety.c,333 :: 		}
L_end_Safety_Run:
	RETURN
; end of _Safety_Run
