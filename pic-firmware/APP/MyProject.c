/*
 * MyProject.c
 * Smart Irrigation Controller — PIC16F877A @ 8 MHz
 * Compiler: MPLAB XC8 v2.36
 *
 * Hardware: single-channel relay on RD0 (pump only). Motor relay removed.
 *
 * FILE STRUCTURE
 *   Section 1 — Production main  (#if 0 … #endif)
 *               Full system: 2 plants 10 cm apart, 5-min cycle, Pi comms,
 *               all sensors, safety, auto/manual modes.
 *   Section 2 — Debug main  (active)
 *               No Pi, no timer. Motor oscillates: 5 cm fwd every 10 s,
 *               reverses after 10 cm. Shaft freed between moves.
 *
 * To activate production: change #if 0 → #if 1 and #if 1 → #if 0 below.
 */

#include "../config.h"
#include "../MCAL/MCU_Registers.h"

#pragma config FOSC = HS
#pragma config WDTE = OFF
#pragma config PWRTE = ON
#pragma config BOREN = ON
#pragma config LVP = OFF
#pragma config CPD = OFF
#pragma config WRT = OFF
#pragma config CP = OFF

#include "../HAL/LCD/LCD_interface.h"
#include "../SERVICES/STD_TYPES.h"
#include "../SERVICES/BIT_MATH.h"

/*
 * portd_shadow — RD0 = pump relay (active LOW, pump OFF = 1).
 * Starting at 0x01 keeps E/RS/D4-D7 LOW so LCD_Init gets a clean start.
 */
volatile u8 portd_shadow = 0x00u;
u8 last_temp_c = 25u;
volatile u8 g_tick_100ms = 0u;
u8 g_frame[4] = {0u};
u8 g_frame_idx = 0u;
u8 g_frame_ready = 0u;

/* ═══════════════════════════════════════════════════════════════════════════
   SECTION 1 — PRODUCTION MAIN  (flip to #if 1 to activate)
   2 plants, 10 cm apart. 5-min auto cycle. Full sensors + Pi comms.
   ═══════════════════════════════════════════════════════════════════════════ */
#if 0

#include "Safety/Safety_interface.h"
#include "Comms/Comms_interface.h"
#include "Irrigation/Irrigation_interface.h"
#include "../HAL/Buzzer/Buzzer_interface.h"
#include "../HAL/Button/Button_interface.h"
#include "../HAL/Fan/Fan_interface.h"
#include "../HAL/Humidity/Humidity_interface.h"
#include "../HAL/Ultrasonic/Ultrasonic_interface.h"
#include "../HAL/Motor/Motor_interface.h"
#include "../MCAL/ADC/ADC_interface.h"
#include "../MCAL/USART/USART_interface.h"

void main(void)
{
    u16 tick        = 0u;
    u8  lcd_page    = 0u;
    u8  current_mode = MODE_AUTO;
    u8  new_mode;
    u8  soil_pct = 0u;
    u8  humidity = 50u;
    u8  water_cm = 20u;
    u16 curr_mA  = 0u;

    /* ── Port config ── */
    ADCON1 = ADCON1_CONFIG;
    TRISA  = 0x07u;
    PORTB  = 0x00u;
    TRISB  = 0b00011011u;
    TRISC  = 0b10000000u;   /* RC7 = UART RX input */
    TRISD  = 0x00u;
    TRISE  = 0x00u;
    CLR_BIT(OPTION_REG, 7u);

    PORTD = portd_shadow;
    SET_BIT(PORTC, PIN_ENABLE);
    CLR_BIT(PORTC, PIN_TRIG);
    CLR_BIT(PORTC, PIN_DIR);
    CLR_BIT(PORTC, PIN_STEP);
    CLR_BIT(PORTC, PIN_FAN);
    SET_BIT(PORTC, 6u);         /* UART TX idle HIGH */
    CLR_BIT(PORTB, PIN_BUZZ);
    CLR_BIT(PORTE, PIN_LED_YLW);
    CLR_BIT(PORTE, PIN_LED_RED);

    /* ── Driver init ── */
    ADC_Init();
    UART_Init();
    LCD_Init();
    Safety_Init();
    Button_Init();
    Fan_Init();
    Humidity_Init();
    Buzzer_Init();

    LCD_GoToRowCol(1u, 1u); LCD_SendString_Const("Smart Irrigation");
    LCD_GoToRowCol(2u, 1u); LCD_SendString_Const(" Initializing...");
    { u8 s; for (s = 0u; s < 15u; s++) { __delay_ms(100); } }

    LCD_GoToRowCol(1u, 1u); LCD_SendString_Const("Waiting for Pi  ");
    LCD_GoToRowCol(2u, 1u); LCD_SendString_Const("                ");
    while (!Comms_HandshakeReceived()) { __delay_ms(100); Comms_Poll(); }
    Comms_SendHandshakeAck();

    LCD_GoToRowCol(1u, 1u); LCD_SendString_Const("Pi Ready!       ");
    LCD_GoToRowCol(2u, 1u); LCD_SendString_Const("Starting...     ");
    { u8 s; for (s = 0u; s < 15u; s++) { __delay_ms(100); } }
    LCD_Clear();

    Comms_SendStatus(MODE_AUTO, 0u);

    /* ── Main loop (1 tick = 100 ms) ── */
    while (1)
    {
        __delay_ms(100);
        tick++;

        Button_Poll();
        Comms_Poll();

        new_mode = Comms_GetMode();
        if (new_mode != current_mode)
        {
            u8 was_auto = (u8)(current_mode == MODE_AUTO);
            current_mode = new_mode;

            /* Force-stop any auto activity when leaving AUTO */
            if (was_auto && current_mode == MODE_MANUAL) {
                u8 pos = Motor_GetPositionCm();
                portd_shadow |= (u8)(1u << PIN_PUMP);
                PORTD = portd_shadow;
                LCD_GoToRowCol(1u, 1u);
                LCD_SendString_Const("AUTO->MAN at ");
                LCD_SendNumber((s16)pos);
                LCD_SendString_Const("cm");
                LCD_GoToRowCol(2u, 1u);
                LCD_SendString_Const("Homing...       ");
                Motor_Home();
                Motor_Disable();
                tick = 0u;
            }

            Comms_SendStatus(current_mode, Safety_IsLocked());
            LCD_GoToRowCol(2u, 1u);
            LCD_SendString_Const(current_mode == MODE_AUTO ? "Auto Mode OK    "
                                                            : "Manual Mode     ");
        }

        /* Estop edge — show pos, home, hold until released */
        if (Button_IsEstopped() || Comms_AppEstopActive())
        {
            u8 pos = Motor_GetPositionCm();
            portd_shadow |= (u8)(1u << PIN_PUMP);
            PORTD = portd_shadow;
            LCD_GoToRowCol(1u, 1u);
            LCD_SendString_Const("ESTOP at ");
            LCD_SendNumber((s16)pos);
            LCD_SendString_Const("cm   ");
            LCD_GoToRowCol(2u, 1u);
            LCD_SendString_Const("Home + wait     ");
            Motor_Home();
            Motor_Disable();
            while (Button_IsEstopped() || Comms_AppEstopActive()) {
                __delay_ms(100);
                Button_Poll();
                Comms_Poll();
            }
            LCD_GoToRowCol(2u, 1u);
            LCD_SendString_Const("Resumed         ");
            tick = 0u;
        }

        if (current_mode == MODE_MANUAL && Comms_ManualCommandPending())
        {
            u8 plant = Comms_GetManualPlant();
            Comms_ClearManualCommand();
            if (!Safety_IsLocked() && !Button_IsEstopped() && !Comms_AppEstopActive())
                Irrigation_RunSinglePlant(plant);
        }

        /* Manual pump on/off from app (esp/pump cmd via Pi) */
        if (current_mode == MODE_MANUAL && Comms_PumpCommandPending())
        {
            u8 pstate = Comms_GetPumpState();
            u8 pplant = Comms_GetPumpPlant();
            Comms_ClearPumpCommand();
            if (pstate == 0u) {
                Irrigation_PumpOff();
            } else if (!Safety_IsLocked() && !Button_IsEstopped() && !Comms_AppEstopActive()) {
                Irrigation_PumpOnAt(pplant);
            }
        }

        /* Safety override: kill pump if locked/estopped while manually on */
        if (Safety_IsLocked() || Button_IsEstopped() || Comms_AppEstopActive())
        {
            portd_shadow |= (u8)(1u << PIN_PUMP);
            PORTD = portd_shadow;
        }

        /* Sensor read every 2 s */
        if ((tick % SENSOR_PERIOD_TICKS) == 0u)
        {
            soil_pct = ADC_SoilPct(ADC_Read(ADC_CH_SOIL));
            curr_mA  = ADC_CurrentmA(ADC_Read(ADC_CH_CURRENT));
            water_cm = Ultrasonic_GetWaterLevel();
            Humidity_Read(&humidity, &last_temp_c);
            Safety_RunChecks(soil_pct, last_temp_c, curr_mA, water_cm);
            Comms_SendSensors(soil_pct, last_temp_c, humidity, curr_mA, water_cm);

            LCD_GoToRowCol(1u, 1u);
            switch (lcd_page % 5u)
            {
            case 0u: LCD_SendString_Const("Soil:"); LCD_SendNumber((s16)soil_pct); LCD_SendString_Const("%          "); break;
            case 1u: LCD_SendString_Const("Temp:"); LCD_SendNumber((s16)last_temp_c); LCD_SendString_Const("C          "); break;
            case 2u: LCD_SendString_Const("Hum :"); LCD_SendNumber((s16)humidity); LCD_SendString_Const("%          "); break;
            case 3u: LCD_SendString_Const("Curr:"); LCD_SendNumber((s16)curr_mA); LCD_SendString_Const("mA     "); break;
            case 4u: LCD_SendString_Const("Watr:"); LCD_SendNumber((s16)water_cm); LCD_SendString_Const("cm         "); break;
            default: break;
            }
            lcd_page++;

            if (!Safety_IsLocked())
            {
                LCD_GoToRowCol(2u, 1u);
                if (Button_IsEstopped() || Comms_AppEstopActive())
                    LCD_SendString_Const("E-STOP ACTIVE   ");
                else if (current_mode == MODE_MANUAL)
                    LCD_SendString_Const("Manual Mode     ");
                else
                    LCD_SendString_Const("Auto Mode OK    ");
            }
        }

        /* Irrigation every 5 min */
        if (current_mode == MODE_AUTO && tick >= IRRIG_PERIOD_TICKS)
        {
            tick = 0u;
            if (!Safety_IsLocked() && !Button_IsEstopped() && !Comms_AppEstopActive())
                Irrigation_RunCycle();
        }

        if (current_mode == MODE_MANUAL && tick >= IRRIG_PERIOD_TICKS)
            tick = 0u;
    }
}

#endif /* SECTION 1 — PRODUCTION MAIN */

/* ═══════════════════════════════════════════════════════════════════════════
   SECTION 2 — DEBUG MAIN  (active — flip to #if 0 when going to production)
   Verify full pipeline without 5-min timer or Pi handshake gate.
   Cycle: move 5 cm to plant → read all sensors → send to Pi → signal photo
          → Pi uploads to Firebase → next plant → … → bounce back → repeat.
   ═══════════════════════════════════════════════════════════════════════════ */
#if 1

#include "Comms/Comms_interface.h"
#include "../HAL/Button/Button_interface.h"
#include "../HAL/Motor/Motor_interface.h"
#include "../HAL/Humidity/Humidity_interface.h"
#include "../HAL/Ultrasonic/Ultrasonic_interface.h"
#include "../MCAL/ADC/ADC_interface.h"
#include "../MCAL/USART/USART_interface.h"

/* Time given to Pi to capture image and upload to Firebase */
#define PI_PHOTO_WAIT_TICKS 200u /* 200 × 100 ms = 20 s */

static u8 estop_now(void)
{
    Button_Poll();
    Comms_Poll();
    return (u8)(Button_IsEstopped() || Comms_AppEstopActive());
}

static void handle_estop(void)
{
    u8 pos_cm = Motor_GetPositionCm();

    LCD_Clear();
    LCD_GoToRowCol(1u, 1u);
    LCD_SendString_Const("E-STOP at ");
    LCD_SendNumber((s16)pos_cm);
    LCD_SendString_Const("cm   ");
    LCD_GoToRowCol(2u, 1u);
    LCD_SendString_Const("Stopping...     ");

    {
        u8 s;
        for (s = 0u; s < 10u; s++)
        {
            __delay_ms(100);
        }
    }

    LCD_GoToRowCol(2u, 1u);
    LCD_SendString_Const("Reset motor->0  ");
    Motor_Home();
    Motor_Disable();

    LCD_GoToRowCol(2u, 1u);
    LCD_SendString_Const("At home. Waiting");

    /* Wait until both estop sources clear (hw button toggle / app release) */
    while (1)
    {
        __delay_ms(100);
        Button_Poll();
        Comms_Poll();
        if (!Button_IsEstopped() && !Comms_AppEstopActive())
            break;
    }

    LCD_Clear();
    LCD_GoToRowCol(1u, 1u);
    LCD_SendString_Const("Resumed         ");
    {
        u8 s;
        for (s = 0u; s < 10u; s++)
        {
            __delay_ms(100);
        }
    }
}

/* Render row 1 with one of 5 sensor pages. Page cycles every PAGE_TICKS. */
#define PAGE_TICKS 40u /* 40 × 100 ms = 4 s per page → 5 pages in 20 s */

static void render_sensor_page(u8 plant_idx, u8 page,
                               u8 soil, u8 temp, u8 hum, u16 curr, u8 water)
{
    LCD_GoToRowCol(1u, 1u);
    LCD_SendString_Const("P");
    LCD_SendNumber((s16)plant_idx);
    LCD_SendString_Const(" ");
    switch (page % 5u)
    {
    case 0u:
        LCD_SendString_Const("Soil:");
        LCD_SendNumber((s16)soil);
        LCD_SendString_Const("%        ");
        break;
    case 1u:
        LCD_SendString_Const("Temp:");
        LCD_SendNumber((s16)temp);
        LCD_SendString_Const("C        ");
        break;
    case 2u:
        LCD_SendString_Const("Hum:");
        LCD_SendNumber((s16)hum);
        LCD_SendString_Const("%         ");
        break;
    case 3u:
        LCD_SendString_Const("Cur:");
        LCD_SendNumber((s16)curr);
        LCD_SendString_Const("mA     ");
        break;
    case 4u:
        LCD_SendString_Const("Wtr:");
        LCD_SendNumber((s16)water);
        LCD_SendString_Const("cm        ");
        break;
    default:
        break;
    }
}

static void read_and_signal(u8 plant_idx)
{
    u8 soil, humidity, water;
    u16 curr;
    u8 t, page = 0u;

    soil = ADC_SoilPct(ADC_Read(ADC_CH_SOIL));
    curr = ADC_CurrentmA(ADC_Read(ADC_CH_CURRENT));
    water = Ultrasonic_GetWaterLevel();
    Humidity_Read(&humidity, &last_temp_c);

    /* Send sensor packet then trigger Pi camera */
    Comms_SendSensors(soil, last_temp_c, humidity, curr, water);
    Comms_SendAtPlant(plant_idx);

    LCD_GoToRowCol(2u, 1u);
    LCD_SendString_Const("Pi: uploading...");

    render_sensor_page(plant_idx, page, soil, last_temp_c, humidity, curr, water);

    for (t = 0u; t < PI_PHOTO_WAIT_TICKS; t++)
    {
        __delay_ms(100);
        if (estop_now())
        {
            handle_estop();
            return;
        }
        if (((t + 1u) % PAGE_TICKS) == 0u)
        {
            page++;
            render_sensor_page(plant_idx, page, soil, last_temp_c,
                               humidity, curr, water);
        }
    }
}

void main(void)
{
    /* plant_idx alternates 0 → 1 → 0 → 1 … bouncing between both plants */
    u8 plant_idx = 0u;

    /* ── Port config ── */
    ADCON1 = ADCON1_CONFIG;
    TRISA = 0x07u;
    PORTB = 0x00u;
    TRISB = 0b00011011u;
    TRISC = 0b10000000u; /* RC7 = UART RX input */
    TRISD = 0x00u;
    TRISE = 0x00u;
    CLR_BIT(OPTION_REG, 7u);

    PORTD = portd_shadow;
    SET_BIT(PORTC, PIN_ENABLE);
    CLR_BIT(PORTC, PIN_TRIG);
    CLR_BIT(PORTC, PIN_DIR);
    CLR_BIT(PORTC, PIN_STEP);
    CLR_BIT(PORTC, PIN_FAN);
    SET_BIT(PORTC, 6u); /* UART TX idle HIGH */
    CLR_BIT(PORTB, PIN_BUZZ);
    CLR_BIT(PORTE, PIN_LED_YLW);
    CLR_BIT(PORTE, PIN_LED_RED);

    ADC_Init();
    UART_Init();
    LCD_Init();
    Button_Init();
    Humidity_Init();
    Motor_Init();

    LCD_GoToRowCol(1u, 1u);
    LCD_SendString_Const("Debug: Sense+   ");
    LCD_GoToRowCol(2u, 1u);
    LCD_SendString_Const("Photo Pipeline  ");
    {
        u8 s;
        for (s = 0u; s < 20u; s++)
        {
            __delay_ms(100);
        }
    } /* 2 s splash */

    while (1)
    {
        /* Estop check before move */
        if (estop_now())
        {
            handle_estop();
            plant_idx = 0u;
            continue;
        }

        /* Move to next plant. P0 = 3 cm from home, P1 = 13 cm (10 cm apart) */
        LCD_GoToRowCol(1u, 1u);
        LCD_SendString_Const("Moving -> P");
        LCD_SendNumber((s16)plant_idx);
        LCD_SendString_Const("    ");
        LCD_GoToRowCol(2u, 1u);
        LCD_SendString_Const(plant_idx == 0u ? "to 3cm          "
                                             : "to 13cm         ");

        Motor_MoveTo(plant_idx);
        Motor_Disable();

        if (estop_now())
        {
            handle_estop();
            plant_idx = 0u;
            continue;
        }

        /* Read sensors, send to Pi, signal photo, wait for upload */
        read_and_signal(plant_idx);

        /* Bounce: 0 → 1 → 0 → 1 … */
        plant_idx ^= 1u;
    }
}

#endif /* SECTION 2 — DEBUG MAIN */
