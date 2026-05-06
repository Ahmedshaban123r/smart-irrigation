#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Current/Current.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/current_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 11 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/current_interface.h"
void Current_Init(void);
s16 Current_Read_mA(void);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/current_config.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../mcal/adc/adc_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../mcal/adc/../../services/std_types.h"
#line 23 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../mcal/adc/adc_interface.h"
void ADC_Init(void);
#line 32 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../mcal/adc/adc_interface.h"
u16 ADC_Read(u8 channel);
#line 40 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../mcal/adc/adc_interface.h"
u16 ADC_ReadAverage(u8 channel, u8 samples);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../mcal/adc/adc_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/current/../../services/std_types.h"
#line 11 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Current/Current.c"
void Current_Init(void)
{

}

s16 Current_Read_mA(void)
{
 u16 raw = 0;
 u32 vout_mv = 0;
 s32 vdelta = 0;
 s16 current = 0;

 raw = ADC_ReadAverage( 2u ,  8u );

 vout_mv = ((u32)raw *  5000u ) /  1024u ;
 vdelta = (s32)vout_mv - (s32) 2500u ;

 current = (s16)((vdelta * 1000) / (s32) 66u );

 return current;
}
