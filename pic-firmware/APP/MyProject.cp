#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/APP/MyProject.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 21 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_Init(void);
#line 27 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_SendCommand(u8 cmd);


void LCD_SendString_Const(const char *str);
#line 36 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_SendChar(u8 ch);
#line 43 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_SendString(char *str);
#line 49 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_SendNumber(s16 num);
#line 55 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_GoToRowCol(u8 row, u8 col);
#line 61 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_Clear(void);
#line 68 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/lcd/lcd_interface.h"
void LCD_DisplayStatus(u8 row, char *label, s16 value, char *unit);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/humidity/humidity_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/humidity/../../services/std_types.h"
#line 22 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/humidity/humidity_interface.h"
void Humidity_Init(void);
#line 31 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/humidity/humidity_interface.h"
u8 Humidity_Read(u8 *humidity, u8 *temperature);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/soil/soil_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/soil/../../services/std_types.h"
#line 11 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/soil/soil_interface.h"
void Soil_Init(void);
u8 Soil_Read_Pct(void);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/current/current_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/current/../../services/std_types.h"
#line 11 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../hal/current/current_interface.h"
void Current_Init(void);
s16 Current_Read_mA(void);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../mcal/adc/adc_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../mcal/adc/../../services/std_types.h"
#line 23 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../mcal/adc/adc_interface.h"
void ADC_Init(void);
#line 32 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../mcal/adc/adc_interface.h"
u16 ADC_Read(u8 channel);
#line 40 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../mcal/adc/adc_interface.h"
u16 ADC_ReadAverage(u8 channel, u8 samples);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/app/../services/std_types.h"
#line 25 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/APP/MyProject.c"
volatile u8 g_tick_100ms = 0;
u8 g_frame[4] = {0};
u8 g_frame_idx = 0;
u8 g_frame_ready = 0;

void main(void)
{
 u8 humidity = 0;
 u8 temperature = 0;
 u8 soil_pct = 0;
 s16 current_mA = 0;
 u8 dht_status = 0;
 u8 page = 0;


 Delay_ms(100);

 ADC_Init();
 LCD_Init();
 Humidity_Init();
 Soil_Init();
 Current_Init();


 LCD_GoToRowCol( 1u , 1);
 LCD_SendString_Const(" Sensor Test    ");
 LCD_GoToRowCol( 2u , 1);
 LCD_SendString_Const(" Initializing...");
 Delay_ms(1500);
 LCD_Clear();

 while(1)
 {

 dht_status = Humidity_Read(&humidity, &temperature);
 soil_pct = Soil_Read_Pct();
 current_mA = Current_Read_mA();

 if(page == 0)
 {

 LCD_GoToRowCol( 1u , 1);
 if(dht_status ==  0u )
 {
 LCD_SendString_Const("Hum : ");
 LCD_SendNumber((s16)humidity);
 LCD_SendString_Const(" %      ");
 }
 else
 {
 LCD_SendString_Const("DHT11 Error:    ");
 LCD_GoToRowCol( 2u , 1);
 LCD_SendString_Const("Code: ");
 LCD_SendNumber((s16)dht_status);
 LCD_SendString_Const("          ");
 }

 if(dht_status ==  0u )
 {
 LCD_GoToRowCol( 2u , 1);
 LCD_SendString_Const("Temp: ");
 LCD_SendNumber((s16)temperature);
 LCD_SendString_Const(" C      ");
 }
 }
 else
 {

 LCD_GoToRowCol( 1u , 1);
 LCD_SendString_Const("Soil: ");
 LCD_SendNumber((s16)soil_pct);
 LCD_SendString_Const(" %      ");

 LCD_GoToRowCol( 2u , 1);
 LCD_SendString_Const("Curr: ");
 LCD_SendNumber(current_mA);
 LCD_SendString_Const(" mA  ");
 }

 page ^= 1u;

 Delay_ms(2000);
 }
}
