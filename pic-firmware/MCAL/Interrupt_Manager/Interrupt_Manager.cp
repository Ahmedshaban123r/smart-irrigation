#line 1 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/Interrupt_Manager/Interrupt_Manager.c"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/interrupt_manager_interface.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/../../services/bit_math.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/interrupt_manager_private.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/interrupt_manager_config.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/../mcu_registers.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/../../services/std_types.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/../../services/delay.h"
#line 1 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/../../services/std_types.h"
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/../../services/delay.h"
void Generic_Delay_ms(u16 ms);
void Generic_Delay_us(u16 us);
#line 1 "c:/users/public/documents/mikroelektronika/mikroc pro for pic/include/stddef.h"




typedef int ptrdiff_t;
typedef int ptrdiffram_t;
typedef long int ptrdiffrom_t;


typedef unsigned int size_t;
typedef unsigned int sizeram_t;
typedef unsigned long int sizerom_t;


typedef unsigned char wchar_t;
#line 16 "e:/cie year 3/spring 2026/cie 406 (embedded systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/mcal/interrupt_manager/interrupt_manager_interface.h"
extern void TIMER0_ISR(void);
extern void UART_ISR(void);
#line 12 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/Interrupt_Manager/Interrupt_Manager.c"
extern volatile u8 g_tick_100ms;
extern u8 g_frame[4];
extern u8 g_frame_idx;
extern u8 g_frame_ready;
#line 21 "E:/CIE Year 3/Spring 2026/CIE 406 (Embedded Systems)/smart-irrigation-main/smart-irrigation-main/pic-firmware/MCAL/Interrupt_Manager/Interrupt_Manager.c"
 void interrupt() 
{

 if ( ( (( (*((volatile u8*)0x0B)) ) >> ( 2 )) & 1U ) ) {

  ( ( (*((volatile u8*)0x0B)) ) &= ~(1U << ( 2 )) ) ;
 g_tick_100ms = 1;
 }


 if ( ( (( (*((volatile u8*)0x0C)) ) >> ( 5 )) & 1U ) ) {
 u8 b =  (*((volatile u8*)0x1A)) ;


 if(g_frame_idx == 0u) {
 if(b ==  0xCC ) {
 g_frame[0] = b;
 g_frame_idx = 1u;
 }
 }
 else if(g_frame_idx < 3u) {
 g_frame[g_frame_idx++] = b;
 }
 else {
 g_frame[3] = b;
 g_frame_idx = 0u;
 if(b ==  0xDD ) {
 g_frame_ready = 1u;
 }
 }
 }
}
