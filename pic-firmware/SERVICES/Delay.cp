#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/SERVICES/Delay.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/services/delay.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 9 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/SERVICES/Delay.c"
void Generic_Delay_ms(u16 ms)
{

 volatile u16 i, j;

 for(i = 0; i < ms; i++)
 {
#line 19 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/SERVICES/Delay.c"
 for(j = 0; j < 180; j++)
 {

 }
 }
}

void Generic_Delay_us(u16 us)
{
 volatile u16 i, j;

 for(i = 0; i < us; i++)
 {
#line 35 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/SERVICES/Delay.c"
 for(j = 0; j < 2; j++)
 {

 }
 }
}
