
LCD_LCD_SendNibble:

;LCD.c,5 :: 		static void LCD_SendNibble(u8 nibble)
;LCD.c,7 :: 		if (GET_BIT(nibble, 4)) SET_BIT(LCD_DATA_PORT, LCD_D4_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D4_PIN);
	MOVF       FARG_LCD_LCD_SendNibble_nibble+0, 0
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
	GOTO       L_LCD_LCD_SendNibble0
	BSF        8, 4
	GOTO       L_LCD_LCD_SendNibble1
L_LCD_LCD_SendNibble0:
	MOVLW      239
	ANDWF      8, 1
L_LCD_LCD_SendNibble1:
;LCD.c,8 :: 		if (GET_BIT(nibble, 5)) SET_BIT(LCD_DATA_PORT, LCD_D5_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D5_PIN);
	MOVLW      5
	MOVWF      R0+0
	MOVF       FARG_LCD_LCD_SendNibble_nibble+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L_LCD_LCD_SendNibble43:
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_LCD_SendNibble44
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L_LCD_LCD_SendNibble43
L_LCD_LCD_SendNibble44:
	BTFSS      R1+0, 0
	GOTO       L_LCD_LCD_SendNibble2
	BSF        8, 5
	GOTO       L_LCD_LCD_SendNibble3
L_LCD_LCD_SendNibble2:
	MOVLW      223
	ANDWF      8, 1
L_LCD_LCD_SendNibble3:
;LCD.c,9 :: 		if (GET_BIT(nibble, 6)) SET_BIT(LCD_DATA_PORT, LCD_D6_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D6_PIN);
	MOVLW      6
	MOVWF      R0+0
	MOVF       FARG_LCD_LCD_SendNibble_nibble+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L_LCD_LCD_SendNibble45:
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_LCD_SendNibble46
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L_LCD_LCD_SendNibble45
L_LCD_LCD_SendNibble46:
	BTFSS      R1+0, 0
	GOTO       L_LCD_LCD_SendNibble4
	BSF        8, 6
	GOTO       L_LCD_LCD_SendNibble5
L_LCD_LCD_SendNibble4:
	MOVLW      191
	ANDWF      8, 1
L_LCD_LCD_SendNibble5:
;LCD.c,10 :: 		if (GET_BIT(nibble, 7)) SET_BIT(LCD_DATA_PORT, LCD_D7_PIN); else CLR_BIT(LCD_DATA_PORT, LCD_D7_PIN);
	MOVLW      7
	MOVWF      R0+0
	MOVF       FARG_LCD_LCD_SendNibble_nibble+0, 0
	MOVWF      R1+0
	MOVF       R0+0, 0
L_LCD_LCD_SendNibble47:
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_LCD_SendNibble48
	RRF        R1+0, 1
	BCF        R1+0, 7
	ADDLW      255
	GOTO       L_LCD_LCD_SendNibble47
L_LCD_LCD_SendNibble48:
	BTFSS      R1+0, 0
	GOTO       L_LCD_LCD_SendNibble6
	BSF        8, 7
	GOTO       L_LCD_LCD_SendNibble7
L_LCD_LCD_SendNibble6:
	MOVLW      127
	ANDWF      8, 1
L_LCD_LCD_SendNibble7:
;LCD.c,12 :: 		SET_BIT(LCD_CTRL_PORT, LCD_E_PIN);
	BSF        8, 2
;LCD.c,13 :: 		Delay_us(LCD_ENABLE_PULSE_US);
	MOVLW      6
	MOVWF      R13+0
L_LCD_LCD_SendNibble8:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_LCD_SendNibble8
	NOP
;LCD.c,14 :: 		CLR_BIT(LCD_CTRL_PORT, LCD_E_PIN);
	MOVLW      251
	ANDWF      8, 1
;LCD.c,15 :: 		Delay_us(LCD_ENABLE_PULSE_US);
	MOVLW      6
	MOVWF      R13+0
L_LCD_LCD_SendNibble9:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_LCD_SendNibble9
	NOP
;LCD.c,16 :: 		}
L_end_LCD_SendNibble:
	RETURN
; end of LCD_LCD_SendNibble

LCD_LCD_SendByte:

;LCD.c,18 :: 		static void LCD_SendByte(u8 byte, u8 rs)
;LCD.c,20 :: 		if (rs == 1) SET_BIT(LCD_CTRL_PORT, LCD_RS_PIN);
	MOVF       FARG_LCD_LCD_SendByte_rs+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_LCD_LCD_SendByte10
	BSF        8, 0
	GOTO       L_LCD_LCD_SendByte11
L_LCD_LCD_SendByte10:
;LCD.c,21 :: 		else CLR_BIT(LCD_CTRL_PORT, LCD_RS_PIN);
	MOVLW      254
	ANDWF      8, 1
L_LCD_LCD_SendByte11:
;LCD.c,23 :: 		CLR_BIT(LCD_CTRL_PORT, LCD_RW_PIN);
	MOVLW      253
	ANDWF      8, 1
;LCD.c,25 :: 		LCD_SendNibble(byte & 0xF0);
	MOVLW      240
	ANDWF      FARG_LCD_LCD_SendByte_byte+0, 0
	MOVWF      FARG_LCD_LCD_SendNibble_nibble+0
	CALL       LCD_LCD_SendNibble+0
;LCD.c,26 :: 		LCD_SendNibble((u8)(byte << 4));
	MOVF       FARG_LCD_LCD_SendByte_byte+0, 0
	MOVWF      FARG_LCD_LCD_SendNibble_nibble+0
	RLF        FARG_LCD_LCD_SendNibble_nibble+0, 1
	BCF        FARG_LCD_LCD_SendNibble_nibble+0, 0
	RLF        FARG_LCD_LCD_SendNibble_nibble+0, 1
	BCF        FARG_LCD_LCD_SendNibble_nibble+0, 0
	RLF        FARG_LCD_LCD_SendNibble_nibble+0, 1
	BCF        FARG_LCD_LCD_SendNibble_nibble+0, 0
	RLF        FARG_LCD_LCD_SendNibble_nibble+0, 1
	BCF        FARG_LCD_LCD_SendNibble_nibble+0, 0
	CALL       LCD_LCD_SendNibble+0
;LCD.c,27 :: 		Delay_ms(LCD_CMD_DELAY_MS);
	MOVLW      6
	MOVWF      R12+0
	MOVLW      48
	MOVWF      R13+0
L_LCD_LCD_SendByte12:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_LCD_SendByte12
	DECFSZ     R12+0, 1
	GOTO       L_LCD_LCD_SendByte12
	NOP
;LCD.c,28 :: 		}
L_end_LCD_SendByte:
	RETURN
; end of LCD_LCD_SendByte

_LCD_Init:

;LCD.c,30 :: 		void LCD_Init(void)
;LCD.c,32 :: 		CLR_BIT(LCD_CTRL_TRIS, LCD_RS_PIN);
	MOVLW      254
	ANDWF      136, 1
;LCD.c,33 :: 		CLR_BIT(LCD_CTRL_TRIS, LCD_RW_PIN);
	MOVLW      253
	ANDWF      136, 1
;LCD.c,34 :: 		CLR_BIT(LCD_CTRL_TRIS, LCD_E_PIN);
	MOVLW      251
	ANDWF      136, 1
;LCD.c,35 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D4_PIN);
	MOVLW      239
	ANDWF      136, 1
;LCD.c,36 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D5_PIN);
	MOVLW      223
	ANDWF      136, 1
;LCD.c,37 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D6_PIN);
	MOVLW      191
	ANDWF      136, 1
;LCD.c,38 :: 		CLR_BIT(LCD_DATA_TRIS, LCD_D7_PIN);
	MOVLW      127
	ANDWF      136, 1
;LCD.c,40 :: 		Delay_ms(LCD_INIT_DELAY_MS);
	MOVLW      52
	MOVWF      R12+0
	MOVLW      241
	MOVWF      R13+0
L_LCD_Init13:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Init13
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Init13
	NOP
	NOP
;LCD.c,42 :: 		CLR_BIT(LCD_CTRL_PORT, LCD_RS_PIN);
	MOVLW      254
	ANDWF      8, 1
;LCD.c,43 :: 		CLR_BIT(LCD_CTRL_PORT, LCD_RW_PIN);
	MOVLW      253
	ANDWF      8, 1
;LCD.c,45 :: 		LCD_SendNibble(0x30);   Delay_ms(5);
	MOVLW      48
	MOVWF      FARG_LCD_LCD_SendNibble_nibble+0
	CALL       LCD_LCD_SendNibble+0
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_Init14:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Init14
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Init14
	NOP
	NOP
;LCD.c,46 :: 		LCD_SendNibble(0x30);   Delay_ms(1);
	MOVLW      48
	MOVWF      FARG_LCD_LCD_SendNibble_nibble+0
	CALL       LCD_LCD_SendNibble+0
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_LCD_Init15:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Init15
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Init15
	NOP
	NOP
;LCD.c,47 :: 		LCD_SendNibble(0x30);   Delay_ms(1);
	MOVLW      48
	MOVWF      FARG_LCD_LCD_SendNibble_nibble+0
	CALL       LCD_LCD_SendNibble+0
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_LCD_Init16:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Init16
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Init16
	NOP
	NOP
;LCD.c,49 :: 		LCD_SendNibble(0x20);   Delay_ms(1);
	MOVLW      32
	MOVWF      FARG_LCD_LCD_SendNibble_nibble+0
	CALL       LCD_LCD_SendNibble+0
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_LCD_Init17:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Init17
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Init17
	NOP
	NOP
;LCD.c,50 :: 		LCD_SendCommand(LCD_CMD_FUNCTION_SET_4BIT);
	MOVLW      40
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,51 :: 		LCD_SendCommand(0x08);
	MOVLW      8
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,52 :: 		LCD_SendCommand(LCD_CMD_CLEAR_DISPLAY);
	MOVLW      1
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,53 :: 		Delay_ms(LCD_CLEAR_DELAY_MS);
	MOVLW      6
	MOVWF      R12+0
	MOVLW      48
	MOVWF      R13+0
L_LCD_Init18:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Init18
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Init18
	NOP
;LCD.c,54 :: 		LCD_SendCommand(LCD_CMD_ENTRY_MODE);
	MOVLW      6
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,55 :: 		LCD_SendCommand(LCD_CMD_DISPLAY_ON);
	MOVLW      12
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,56 :: 		}
L_end_LCD_Init:
	RETURN
; end of _LCD_Init

_LCD_SendCommand:

;LCD.c,58 :: 		void LCD_SendCommand(u8 cmd)
;LCD.c,60 :: 		LCD_SendByte(cmd, 0);
	MOVF       FARG_LCD_SendCommand_cmd+0, 0
	MOVWF      FARG_LCD_LCD_SendByte_byte+0
	CLRF       FARG_LCD_LCD_SendByte_rs+0
	CALL       LCD_LCD_SendByte+0
;LCD.c,61 :: 		}
L_end_LCD_SendCommand:
	RETURN
; end of _LCD_SendCommand

_LCD_SendChar:

;LCD.c,63 :: 		void LCD_SendChar(u8 ch)
;LCD.c,65 :: 		LCD_SendByte(ch, 1);
	MOVF       FARG_LCD_SendChar_ch+0, 0
	MOVWF      FARG_LCD_LCD_SendByte_byte+0
	MOVLW      1
	MOVWF      FARG_LCD_LCD_SendByte_rs+0
	CALL       LCD_LCD_SendByte+0
;LCD.c,66 :: 		}
L_end_LCD_SendChar:
	RETURN
; end of _LCD_SendChar

_LCD_SendString:

;LCD.c,68 :: 		void LCD_SendString(char *str)
;LCD.c,70 :: 		u8 count = 0;
	CLRF       LCD_SendString_count_L0+0
;LCD.c,71 :: 		while(*str && count < LCD_COL_MAX)
L_LCD_SendString19:
	MOVF       FARG_LCD_SendString_str+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_SendString20
	MOVLW      16
	SUBWF      LCD_SendString_count_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendString20
L__LCD_SendString40:
;LCD.c,73 :: 		LCD_SendChar((u8)*str);
	MOVF       FARG_LCD_SendString_str+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,74 :: 		str++;
	INCF       FARG_LCD_SendString_str+0, 1
;LCD.c,75 :: 		count++;
	INCF       LCD_SendString_count_L0+0, 1
;LCD.c,76 :: 		}
	GOTO       L_LCD_SendString19
L_LCD_SendString20:
;LCD.c,77 :: 		}
L_end_LCD_SendString:
	RETURN
; end of _LCD_SendString

_LCD_SendString_Const:

;LCD.c,79 :: 		void LCD_SendString_Const(const char *str)
;LCD.c,81 :: 		u8 count = 0;
	CLRF       LCD_SendString_Const_count_L0+0
;LCD.c,82 :: 		while(*str && count < LCD_COL_MAX)
L_LCD_SendString_Const23:
	MOVF       FARG_LCD_SendString_Const_str+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       FARG_LCD_SendString_Const_str+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_SendString_Const24
	MOVLW      16
	SUBWF      LCD_SendString_Const_count_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendString_Const24
L__LCD_SendString_Const41:
;LCD.c,84 :: 		LCD_SendChar((u8)*str);
	MOVF       FARG_LCD_SendString_Const_str+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       FARG_LCD_SendString_Const_str+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,85 :: 		str++;
	INCF       FARG_LCD_SendString_Const_str+0, 1
	BTFSC      STATUS+0, 2
	INCF       FARG_LCD_SendString_Const_str+1, 1
;LCD.c,86 :: 		count++;
	INCF       LCD_SendString_Const_count_L0+0, 1
;LCD.c,87 :: 		}
	GOTO       L_LCD_SendString_Const23
L_LCD_SendString_Const24:
;LCD.c,88 :: 		}
L_end_LCD_SendString_Const:
	RETURN
; end of _LCD_SendString_Const

_LCD_SendNumber:

;LCD.c,90 :: 		void LCD_SendNumber(s16 num)
;LCD.c,93 :: 		u8    i   = 0;
	CLRF       LCD_SendNumber_i_L0+0
	CLRF       LCD_SendNumber_len_L0+0
;LCD.c,97 :: 		if(num < 0)
	MOVLW      128
	XORWF      FARG_LCD_SendNumber_num+0, 0
	MOVWF      R0+0
	MOVLW      128
	XORLW      0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendNumber27
;LCD.c,99 :: 		num = -num;
	MOVF       FARG_LCD_SendNumber_num+0, 0
	SUBLW      0
	MOVWF      FARG_LCD_SendNumber_num+0
;LCD.c,100 :: 		LCD_SendChar('-');
	MOVLW      45
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,101 :: 		}
L_LCD_SendNumber27:
;LCD.c,103 :: 		if(num == 0)
	MOVF       FARG_LCD_SendNumber_num+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_LCD_SendNumber28
;LCD.c,105 :: 		LCD_SendChar('0');
	MOVLW      48
	MOVWF      FARG_LCD_SendChar_ch+0
	CALL       _LCD_SendChar+0
;LCD.c,106 :: 		return;
	GOTO       L_end_LCD_SendNumber
;LCD.c,107 :: 		}
L_LCD_SendNumber28:
;LCD.c,109 :: 		while(num > 0)
L_LCD_SendNumber29:
	MOVLW      128
	XORLW      0
	MOVWF      R0+0
	MOVLW      128
	XORWF      FARG_LCD_SendNumber_num+0, 0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendNumber30
;LCD.c,111 :: 		tmp[i++] = (char)('0' + (num % 10));
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
;LCD.c,112 :: 		num /= 10;
	MOVLW      10
	MOVWF      R4+0
	MOVF       FARG_LCD_SendNumber_num+0, 0
	MOVWF      R0+0
	CALL       _Div_8X8_S+0
	MOVF       R0+0, 0
	MOVWF      FARG_LCD_SendNumber_num+0
;LCD.c,113 :: 		}
	GOTO       L_LCD_SendNumber29
L_LCD_SendNumber30:
;LCD.c,114 :: 		len = i;
	MOVF       LCD_SendNumber_i_L0+0, 0
	MOVWF      LCD_SendNumber_len_L0+0
;LCD.c,116 :: 		for(i = 0; i < len; i++)
	CLRF       LCD_SendNumber_i_L0+0
L_LCD_SendNumber31:
	MOVF       LCD_SendNumber_len_L0+0, 0
	SUBWF      LCD_SendNumber_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_SendNumber32
;LCD.c,118 :: 		buf[i] = tmp[len - 1 - i];
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
;LCD.c,116 :: 		for(i = 0; i < len; i++)
	INCF       LCD_SendNumber_i_L0+0, 1
;LCD.c,119 :: 		}
	GOTO       L_LCD_SendNumber31
L_LCD_SendNumber32:
;LCD.c,120 :: 		buf[len] = '\0';
	MOVF       LCD_SendNumber_len_L0+0, 0
	ADDLW      LCD_SendNumber_buf_L0+0
	MOVWF      FSR
	CLRF       INDF+0
;LCD.c,122 :: 		LCD_SendString(buf);
	MOVLW      LCD_SendNumber_buf_L0+0
	MOVWF      FARG_LCD_SendString_str+0
	CALL       _LCD_SendString+0
;LCD.c,123 :: 		}
L_end_LCD_SendNumber:
	RETURN
; end of _LCD_SendNumber

_LCD_GoToRowCol:

;LCD.c,125 :: 		void LCD_GoToRowCol(u8 row, u8 col)
;LCD.c,127 :: 		u8 address = 0;
	CLRF       LCD_GoToRowCol_address_L0+0
;LCD.c,129 :: 		if(col  < 1)  col  = 1;
	MOVLW      1
	SUBWF      FARG_LCD_GoToRowCol_col+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_GoToRowCol34
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_col+0
L_LCD_GoToRowCol34:
;LCD.c,130 :: 		if(col  > 16) col  = 16;
	MOVF       FARG_LCD_GoToRowCol_col+0, 0
	SUBLW      16
	BTFSC      STATUS+0, 0
	GOTO       L_LCD_GoToRowCol35
	MOVLW      16
	MOVWF      FARG_LCD_GoToRowCol_col+0
L_LCD_GoToRowCol35:
;LCD.c,131 :: 		if(row != 2)  row  = 1;
	MOVF       FARG_LCD_GoToRowCol_row+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_GoToRowCol36
	MOVLW      1
	MOVWF      FARG_LCD_GoToRowCol_row+0
L_LCD_GoToRowCol36:
;LCD.c,133 :: 		if(row == 1) address = LCD_CMD_SET_DDRAM + LCD_ROW1_OFFSET + (col - 1);
	MOVF       FARG_LCD_GoToRowCol_row+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_LCD_GoToRowCol37
	DECF       FARG_LCD_GoToRowCol_col+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	ADDLW      128
	MOVWF      LCD_GoToRowCol_address_L0+0
	GOTO       L_LCD_GoToRowCol38
L_LCD_GoToRowCol37:
;LCD.c,134 :: 		else         address = LCD_CMD_SET_DDRAM + LCD_ROW2_OFFSET + (col - 1);
	DECF       FARG_LCD_GoToRowCol_col+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	ADDLW      192
	MOVWF      LCD_GoToRowCol_address_L0+0
L_LCD_GoToRowCol38:
;LCD.c,136 :: 		LCD_SendCommand(address);
	MOVF       LCD_GoToRowCol_address_L0+0, 0
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,137 :: 		}
L_end_LCD_GoToRowCol:
	RETURN
; end of _LCD_GoToRowCol

_LCD_Clear:

;LCD.c,139 :: 		void LCD_Clear(void)
;LCD.c,141 :: 		LCD_SendCommand(LCD_CMD_CLEAR_DISPLAY);
	MOVLW      1
	MOVWF      FARG_LCD_SendCommand_cmd+0
	CALL       _LCD_SendCommand+0
;LCD.c,142 :: 		Delay_ms(LCD_CLEAR_DELAY_MS);
	MOVLW      6
	MOVWF      R12+0
	MOVLW      48
	MOVWF      R13+0
L_LCD_Clear39:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Clear39
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Clear39
	NOP
;LCD.c,143 :: 		}
L_end_LCD_Clear:
	RETURN
; end of _LCD_Clear
