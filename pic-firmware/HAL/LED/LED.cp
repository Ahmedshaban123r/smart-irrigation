#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/LED/LED.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/led/led_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/led/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 14 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/led/led_interface.h"
void LED_Init(u8 Port, u8 Pin);
void LED_On(u8 Port, u8 Pin);
void LED_Off(u8 Port, u8 Pin);
void LED_Toggle(u8 Port, u8 Pin);
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/led/../../mcal/gpio/gpio_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/led/../../mcal/gpio/../../services/std_types.h"
#line 31 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/hal/led/../../mcal/gpio/gpio_interface.h"
void SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GetPinValue(u8 Port, u8 Pin);
void SetPortDirection(u8 Port, u8 Direction);
void SetPortValue(u8 Port, u8 Value);
u8 GetPortValue(u8 Port);
void GPIO_Init(void);
#line 4 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/HAL/LED/LED.c"
void LED_Init(u8 Port, u8 Pin)
{
 SetPinDirection(Port, Pin,  0 );
}

void LED_On(u8 Port, u8 Pin)
{
 SetPinValue(Port, Pin,  1 );
}

void LED_Off(u8 Port, u8 Pin)
{
 SetPinValue(Port, Pin,  0 );
}

void LED_Toggle(u8 Port, u8 Pin)
{
 if(GetPinValue(Port, Pin) ==  1 )
 SetPinValue(Port, Pin,  0 );
 else
 SetPinValue(Port, Pin,  1 );
}
