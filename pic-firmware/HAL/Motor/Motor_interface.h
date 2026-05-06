#ifndef MOTOR_INTERFACE_H
#define MOTOR_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

/*
 * A4988 stepper driver (1/16 microstepping, GT2 20T pulley).
 * RC0=STEP, RC1=DIR, RC2=ENABLE (LOW=enabled, HIGH=disabled).
 * RB3=limit switch (active LOW, triggered at home position).
 */
void Motor_Home(void);
void Motor_MoveTo(u8 plant_index);
void Motor_Disable(void);

#endif /* MOTOR_INTERFACE_H */
