#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Soil/Soil.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/soil_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 11 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/soil_interface.h"
void Soil_Init(void);
u8 Soil_Read_Pct(void);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/soil_config.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../mcal/adc/adc_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../mcal/adc/../../services/std_types.h"
#line 23 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../mcal/adc/adc_interface.h"
void ADC_Init(void);
#line 32 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../mcal/adc/adc_interface.h"
u16 ADC_Read(u8 channel);
#line 40 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../mcal/adc/adc_interface.h"
u16 ADC_ReadAverage(u8 channel, u8 samples);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../mcal/adc/adc_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/soil/../../services/std_types.h"
#line 11 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/Soil/Soil.c"
void Soil_Init(void)
{

}

u8 Soil_Read_Pct(void)
{
 u16 raw = ADC_ReadAverage( 0u ,  4u );
 u8 pct = 0;


 if(raw >=  820u ) return 0u;
 if(raw <=  350u ) return 100u;


 pct = (u8)(((u32)( 820u  - raw) * 100u) /
 ( 820u  -  350u ));

 return pct;
}
