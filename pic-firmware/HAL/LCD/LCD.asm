
_LCD_Init:

;LCD.c,36 :: 		void LCD_Init(void)
;LCD.c,39 :: 		CLR_BIT(LCD_CTRL_TRIS, LCD_RS_PIN);
	MOVLW      251
	ANDWF      136, 1
;LCD.c,40 :: 		CLR_BIT(LCD_CTRL_TRIS, LCD_E_PIN);
	MOVLW      247
	ANDWF      136, 1
;LCD.c,41 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D4_PIN);
	MOVLW      239
	ANDWF      136, 1
;LCD.c,42 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D5_PIN);
	MOVLW      223
	ANDWF      136, 1
;LCD.c,43 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D6_PIN);
	MOVLW      191
	ANDWF      136, 1
;LCD.c,44 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D7_PIN);
	MOVLW      127
	ANDWF      136, 1
;LCD.c,46 :: 		Generic_Delay_ms(LCD_INIT_DELAY_MS);
	MOVLW      20
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,48 :: 		CLR_BIT(LCD_CTRL_PORT, LCD_RS_PIN);
	MOVLW      251
	ANDWF      8, 1
;LCD.c,50 :: 		LCD_SEND_NIBBLE(0x30);   Generic_Delay_ms(5);
	BSF        8, 4
L_LCD_Init4:
	BSF        8, 5
L_LCD_Init6:
L_LCD_Init7:
	MOVLW      191
	ANDWF      8, 1
L_LCD_Init9:
	MOVLW      127
	ANDWF      8, 1
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      5
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,51 :: 		LCD_SEND_NIBBLE(0x30);   Generic_Delay_ms(1);
	BSF        8, 4
L_LCD_Init15:
	BSF        8, 5
L_LCD_Init17:
L_LCD_Init18:
	MOVLW      191
	ANDWF      8, 1
L_LCD_Init20:
	MOVLW      127
	ANDWF      8, 1
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      1
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,52 :: 		LCD_SEND_NIBBLE(0x30);   Generic_Delay_ms(1);
	BSF        8, 4
L_LCD_Init26:
	BSF        8, 5
L_LCD_Init28:
L_LCD_Init29:
	MOVLW      191
	ANDWF      8, 1
L_LCD_Init31:
	MOVLW      127
	ANDWF      8, 1
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      1
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,54 :: 		LCD_SEND_NIBBLE(0x20);   Generic_Delay_ms(1);
L_LCD_Init36:
	MOVLW      239
	ANDWF      8, 1
	BSF        8, 5
L_LCD_Init39:
L_LCD_Init40:
	MOVLW      191
	ANDWF      8, 1
L_LCD_Init42:
	MOVLW      127
	ANDWF      8, 1
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      1
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,56 :: 		LCD_SendCommand(LCD_CMD_FUNCTION_SET_4BIT);
	MOVLW      40
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,57 :: 		LCD_SendCommand(0x08);
	MOVLW      8
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,58 :: 		LCD_SendCommand(LCD_CMD_CLEAR_DISPLAY);
	MOVLW      1
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,59 :: 		Generic_Delay_ms(LCD_CLEAR_DELAY_MS);
	MOVLW      2
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,60 :: 		LCD_SendCommand(LCD_CMD_ENTRY_MODE);
	MOVLW      6
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,61 :: 		LCD_SendCommand(LCD_CMD_DISPLAY_ON);
	MOVLW      12
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,62 :: 		}
L_end_LCD_Init:
	RETURN
; end of _LCD_Init

_LCD_SendCommand:

;LCD.c,67 :: 		void LCD_SendCommand(u8 cmd)
;LCD.c,69 :: 		LCD_SEND_BYTE(cmd, 0);
L_LCD_SendCommand47:
	MOVLW      251
	ANDWF      8, 1
	MOVLW      240
	ANDWF      FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand52
	BSF        8, 4
	GOTO       L_LCD_SendCommand53
L_LCD_SendCommand52:
	MOVLW      239
	ANDWF      8, 1
L_LCD_SendCommand53:
	MOVLW      240
	ANDWF      FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	MOVLW      5
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendCommand122:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendCommand123
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendCommand122
L__LCD_SendCommand123:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand54
	BSF        8, 5
	GOTO       L_LCD_SendCommand55
L_LCD_SendCommand54:
	MOVLW      223
	ANDWF      8, 1
L_LCD_SendCommand55:
	MOVLW      240
	ANDWF      FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	MOVLW      6
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendCommand124:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendCommand125
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendCommand124
L__LCD_SendCommand125:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand56
	BSF        8, 6
	GOTO       L_LCD_SendCommand57
L_LCD_SendCommand56:
	MOVLW      191
	ANDWF      8, 1
L_LCD_SendCommand57:
	MOVLW      240
	ANDWF      FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	MOVLW      7
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendCommand126:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendCommand127
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendCommand126
L__LCD_SendCommand127:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand58
	BSF        8, 7
	GOTO       L_LCD_SendCommand59
L_LCD_SendCommand58:
	MOVLW      127
	ANDWF      8, 1
L_LCD_SendCommand59:
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVF       FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVF       R2+0, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand63
	BSF        8, 4
	GOTO       L_LCD_SendCommand64
L_LCD_SendCommand63:
	MOVLW      239
	ANDWF      8, 1
L_LCD_SendCommand64:
	MOVF       FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVLW      5
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendCommand128:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendCommand129
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendCommand128
L__LCD_SendCommand129:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand65
	BSF        8, 5
	GOTO       L_LCD_SendCommand66
L_LCD_SendCommand65:
	MOVLW      223
	ANDWF      8, 1
L_LCD_SendCommand66:
	MOVF       FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVLW      6
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendCommand130:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendCommand131
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendCommand130
L__LCD_SendCommand131:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand67
	BSF        8, 6
	GOTO       L_LCD_SendCommand68
L_LCD_SendCommand67:
	MOVLW      191
	ANDWF      8, 1
L_LCD_SendCommand68:
	MOVF       FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVLW      7
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendCommand132:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendCommand133
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendCommand132
L__LCD_SendCommand133:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendCommand69
	BSF        8, 7
	GOTO       L_LCD_SendCommand70
L_LCD_SendCommand69:
	MOVLW      127
	ANDWF      8, 1
L_LCD_SendCommand70:
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      2
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,70 :: 		}
L_end_LCD_SendCommand:
	RETURN
; end of _LCD_SendCommand

_LCD_SendChar:

;LCD.c,72 :: 		void LCD_SendChar(u8 ch)
;LCD.c,74 :: 		LCD_SEND_BYTE(ch, 1);
	BSF        8, 2
L_LCD_SendChar75:
	MOVLW      240
	ANDWF      FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar79
	BSF        8, 4
	GOTO       L_LCD_SendChar80
L_LCD_SendChar79:
	MOVLW      239
	ANDWF      8, 1
L_LCD_SendChar80:
	MOVLW      240
	ANDWF      FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	MOVLW      5
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendChar135:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendChar136
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendChar135
L__LCD_SendChar136:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar81
	BSF        8, 5
	GOTO       L_LCD_SendChar82
L_LCD_SendChar81:
	MOVLW      223
	ANDWF      8, 1
L_LCD_SendChar82:
	MOVLW      240
	ANDWF      FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	MOVLW      6
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendChar137:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendChar138
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendChar137
L__LCD_SendChar138:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar83
	BSF        8, 6
	GOTO       L_LCD_SendChar84
L_LCD_SendChar83:
	MOVLW      191
	ANDWF      8, 1
L_LCD_SendChar84:
	MOVLW      240
	ANDWF      FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	MOVLW      7
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendChar139:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendChar140
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendChar139
L__LCD_SendChar140:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar85
	BSF        8, 7
	GOTO       L_LCD_SendChar86
L_LCD_SendChar85:
	MOVLW      127
	ANDWF      8, 1
L_LCD_SendChar86:
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVF       FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVF       R2+0, 0
	MOVWF      R1+0
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	RRF        R1+0, 1
	BCF        R1+0, 7
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar90
	BSF        8, 4
	GOTO       L_LCD_SendChar91
L_LCD_SendChar90:
	MOVLW      239
	ANDWF      8, 1
L_LCD_SendChar91:
	MOVF       FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVLW      5
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendChar141:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendChar142
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendChar141
L__LCD_SendChar142:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar92
	BSF        8, 5
	GOTO       L_LCD_SendChar93
L_LCD_SendChar92:
	MOVLW      223
	ANDWF      8, 1
L_LCD_SendChar93:
	MOVF       FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVLW      6
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendChar143:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendChar144
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendChar143
L__LCD_SendChar144:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar94
	BSF        8, 6
	GOTO       L_LCD_SendChar95
L_LCD_SendChar94:
	MOVLW      191
	ANDWF      8, 1
L_LCD_SendChar95:
	MOVF       FARG_LCD_SendChar_ch+0, 0
	MOVWF      R2+0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	BCF        R2+0, 0
	MOVLW      7
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L__LCD_SendChar145:
	BTFSC      STATUS+0, 2
	GOTO       L__LCD_SendChar146
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L__LCD_SendChar145
L__LCD_SendChar146:
	BTFSS      R1+0, 0
	GOTO       L_LCD_SendChar96
	BSF        8, 7
	GOTO       L_LCD_SendChar97
L_LCD_SendChar96:
	MOVLW      127
	ANDWF      8, 1
L_LCD_SendChar97:
	BSF        8, 3
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      247
	ANDWF      8, 1
	MOVLW      10
	MOVWF      FARG_Generic_Delay_us_us+0
	CALL       _Generic_Delay_us+0
	MOVLW      2
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,75 :: 		}
L_end_LCD_SendChar:
	RETURN
; end of _LCD_SendChar

_LCD_SendString:

;LCD.c,77 :: 		void LCD_SendString(char *str)
;LCD.c,79 :: 		u8 count = 0;
	CLRF       LCD_SendString_count_L0+0
;LCD.c,80 :: 		while(*str && count < LCD_COL_MAX)
L_LCD_SendString98:
	MOVF       FARG_LCD_SendString_str+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_SendString99
	MOVLW      16
	SUBWF      LCD_SendString_count_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendString99
L__LCD_SendString118:
;LCD.c,82 :: 		LCD_SendChar((u8)*str);
	MOVF       FARG_LCD_SendString_str+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,83 :: 		str++; count++;
	INCF       FARG_LCD_SendString_str+0, 1
	INCF       LCD_SendString_count_L0+0, 1
;LCD.c,84 :: 		}
	GOTO       L_LCD_SendString98
L_LCD_SendString99:
;LCD.c,85 :: 		}
L_end_LCD_SendString:
	RETURN
; end of _LCD_SendString

_LCD_SendString_Const:

;LCD.c,87 :: 		void LCD_SendString_Const(const char *str)
;LCD.c,89 :: 		u8 count = 0;
	CLRF       LCD_SendString_Const_count_L0+0
;LCD.c,90 :: 		while(*str && count < LCD_COL_MAX)
L_LCD_SendString_Const102:
	MOVF       FARG_LCD_SendString_Const_str+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       FARG_LCD_SendString_Const_str+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_SendString_Const103
	MOVLW      16
	SUBWF      LCD_SendString_Const_count_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendString_Const103
L__LCD_SendString_Const119:
;LCD.c,92 :: 		LCD_SendChar((u8)*str);
	MOVF       FARG_LCD_SendString_Const_str+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       FARG_LCD_SendString_Const_str+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,93 :: 		str++; count++;
	INCF       FARG_LCD_SendString_Const_str+0, 1
	BTFSC      STATUS+0, 2
	INCF       FARG_LCD_SendString_Const_str+1, 1
	INCF       LCD_SendString_Const_count_L0+0, 1
;LCD.c,94 :: 		}
	GOTO       L_LCD_SendString_Const102
L_LCD_SendString_Const103:
;LCD.c,95 :: 		}
L_end_LCD_SendString_Const:
	RETURN
; end of _LCD_SendString_Const

_LCD_SendNumber:

;LCD.c,97 :: 		void LCD_SendNumber(s16 num)
;LCD.c,100 :: 		u8    i   = 0;
	CLRF       LCD_SendNumber_i_L0+0
	CLRF       LCD_SendNumber_len_L0+0
;LCD.c,105 :: 		if(num < 0) {
	MOVLW      128
	XORWF      FARG_LCD_SendNumber_num+0, 0
	MOVWF      R0+0
	MOVLW      128
	XORLW      0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendNumber106
;LCD.c,107 :: 		num = -num;
	MOVF       FARG_LCD_SendNumber_num+0, 0
	SUBLW      0
	MOVWF      FARG_LCD_SendNumber_num+0
;LCD.c,108 :: 		LCD_SendChar('-');
	MOVLW      45
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,109 :: 		}
L_LCD_SendNumber106:
;LCD.c,110 :: 		if(num == 0) {
	MOVF       FARG_LCD_SendNumber_num+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_LCD_SendNumber107
;LCD.c,111 :: 		LCD_SendChar('0');
	MOVLW      48
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,112 :: 		return;
	GOTO       L_end_LCD_SendNumber
;LCD.c,113 :: 		}
L_LCD_SendNumber107:
;LCD.c,114 :: 		while(num > 0) {
L_LCD_SendNumber108:
	MOVLW      128
	XORLW      0
	MOVWF      R0+0
	MOVLW      128
	XORWF      FARG_LCD_SendNumber_num+0, 0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendNumber109
;LCD.c,115 :: 		tmp[i++] = (char)('0' + (num % 10));
	MOVF       LCD_SendNumber_i_L0+0, 0
	ADDLW      LCD_SendNumber_tmp_L0+0
	MOVWF      FLOC__LCD_SendNumber+0
	MOVLW      10
	MOVWF      R4+0
	MOVF       FARG_LCD_SendNumber_num+0, 0
	MOVWF      R0+0
	CALL       _Div_8X8_S+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 1
	MOVF       FLOC__LCD_SendNumber+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
	INCF       LCD_SendNumber_i_L0+0, 1
;LCD.c,116 :: 		num /= 10;
	MOVLW      10
	MOVWF      R4+0
	MOVF       FARG_LCD_SendNumber_num+0, 0
	MOVWF      R0+0
	CALL       _Div_8X8_S+0
	MOVF       R0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
;LCD.c,117 :: 		}
	GOTO       L_LCD_SendNumber108
L_LCD_SendNumber109:
;LCD.c,118 :: 		len = i;
	MOVF       LCD_SendNumber_i_L0+0, 0
	MOVWF      LCD_SendNumber_len_L0+0
;LCD.c,119 :: 		for(i = 0; i < len; i++) {
	CLRF       LCD_SendNumber_i_L0+0
L_LCD_SendNumber110:
	MOVF       LCD_SendNumber_len_L0+0, 0
	SUBWF      LCD_SendNumber_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendNumber111
;LCD.c,120 :: 		buf[i] = tmp[len - 1 - i];
	MOVF       LCD_SendNumber_i_L0+0, 0
	ADDLW      LCD_SendNumber_buf_L0+0
	MOVWF      R2+0
	MOVLW      1
	SUBWF      LCD_SendNumber_len_L0+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       LCD_SendNumber_i_L0+0, 0
	SUBWF      R0+0, 1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      LCD_SendNumber_tmp_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;LCD.c,119 :: 		for(i = 0; i < len; i++) {
	INCF       LCD_SendNumber_i_L0+0, 1
;LCD.c,121 :: 		}
	GOTO       L_LCD_SendNumber110
L_LCD_SendNumber111:
;LCD.c,122 :: 		buf[len] = '\0';
	MOVF       LCD_SendNumber_len_L0+0, 0
	ADDLW      LCD_SendNumber_buf_L0+0
	MOVWF      FSR
	CLRF       INDF+0
;LCD.c,123 :: 		LCD_SendString(buf);
	MOVLW      LCD_SendNumber_buf_L0+0
	MOVWF      FARG_LCD_SendString_str+0
	CALL       _LCD_SendString+0
;LCD.c,124 :: 		}
L_end_LCD_SendNumber:
	RETURN
; end of _LCD_SendNumber

_LCD_GoToRowCol:

;LCD.c,126 :: 		void LCD_GoToRowCol(u8 row, u8 col)
;LCD.c,128 :: 		u8 address = 0;
	CLRF       LCD_GoToRowCol_address_L0+0
;LCD.c,129 :: 		if(col  < 1)  col  = 1;
	MOVLW      1
	SUBWF      FARG_LCD_GoToRowCol_col+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_GoToRowCol113
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
L_LCD_GoToRowCol113:
;LCD.c,130 :: 		if(col  > 16) col  = 16;
	MOVF       FARG_LCD_GoToRowCol_col+0, 0
	SUBLW      16
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_GoToRowCol114
	MOVLW      16
	MOVWF      FARG_LCD_GoToRowCol_col+0
L_LCD_GoToRowCol114:
;LCD.c,131 :: 		if(row != 2)  row  = 1;
	MOVF       FARG_LCD_GoToRowCol_row+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_GoToRowCol115
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
L_LCD_GoToRowCol115:
;LCD.c,133 :: 		if(row == 1) address = LCD_CMD_SET_DDRAM + LCD_ROW1_OFFSET + (col - 1);
	MOVF       FARG_LCD_GoToRowCol_row+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_LCD_GoToRowCol116
	DECF       FARG_LCD_GoToRowCol_col+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	ADDLW      128
	MOVWF      LCD_GoToRowCol_address_L0+0
	GOTO       L_LCD_GoToRowCol117
L_LCD_GoToRowCol116:
;LCD.c,134 :: 		else         address = LCD_CMD_SET_DDRAM + LCD_ROW2_OFFSET + (col - 1);
	DECF       FARG_LCD_GoToRowCol_col+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	ADDLW      192
	MOVWF      LCD_GoToRowCol_address_L0+0
L_LCD_GoToRowCol117:
;LCD.c,135 :: 		LCD_SendCommand(address);
	MOVF       LCD_GoToRowCol_address_L0+0, 0
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,136 :: 		}
L_end_LCD_GoToRowCol:
	RETURN
; end of _LCD_GoToRowCol

_LCD_Clear:

;LCD.c,138 :: 		void LCD_Clear(void)
;LCD.c,140 :: 		LCD_SendCommand(LCD_CMD_CLEAR_DISPLAY);
	MOVLW      1
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,141 :: 		Generic_Delay_ms(LCD_CLEAR_DELAY_MS);
	MOVLW      2
	MOVWF      FARG_Generic_Delay_ms_ms+0
	CALL       _Generic_Delay_ms+0
;LCD.c,142 :: 		}
L_end_LCD_Clear:
	RETURN
; end of _LCD_Clear
