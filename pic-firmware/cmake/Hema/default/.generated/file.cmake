# The following variables contains the files used by the different stages of the build process.
set(Hema_default_default_XC8_FILE_TYPE_assemble
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/MyProject.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/Safety/Safety.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Buzzer/Buzzer.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Current/Current.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Humidity/Humidity.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/LCD/LCD.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/LED/LED.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Relay/Relay.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Soil/Soil.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Temperature/Temp.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/ADC/ADC.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/GPIO/GPIO.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/Interrupt_Manager/Interrupt_Manager.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/TIMER0/Timer0.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/USART/USART.asm"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../SERVICES/Delay.asm")
set_source_files_properties(${Hema_default_default_XC8_FILE_TYPE_assemble} PROPERTIES LANGUAGE ASM)

# For assembly files, add "." to the include path for each file so that .include with a relative path works
foreach(source_file ${Hema_default_default_XC8_FILE_TYPE_assemble})
        set_source_files_properties(${source_file} PROPERTIES INCLUDE_DIRECTORIES "$<PATH:NORMAL_PATH,$<PATH:REMOVE_FILENAME,${source_file}>>")
endforeach()

set(Hema_default_default_XC8_FILE_TYPE_assemblePreprocess)
set_source_files_properties(${Hema_default_default_XC8_FILE_TYPE_assemblePreprocess} PROPERTIES LANGUAGE ASM)

# For assembly files, add "." to the include path for each file so that .include with a relative path works
foreach(source_file ${Hema_default_default_XC8_FILE_TYPE_assemblePreprocess})
        set_source_files_properties(${source_file} PROPERTIES INCLUDE_DIRECTORIES "$<PATH:NORMAL_PATH,$<PATH:REMOVE_FILENAME,${source_file}>>")
endforeach()

set(Hema_default_default_XC8_FILE_TYPE_compile
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/Comms/Comms.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/Irrigation/Irrigation.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/MyProject.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/Safety/Safety.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/Tests/stepper_test.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../APP/Tests/uart_test.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Button/Button.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Buzzer/Buzzer.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Current/Current.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Fan/Fan.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Humidity/Humidity.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/LCD/LCD.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/LED/LED.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Motor/Motor.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Relay/Relay.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Soil/Soil.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Temperature/Temp.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../HAL/Ultrasonic/Ultrasonic.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/ADC/ADC.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/GPIO/GPIO.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/Interrupt_Manager/Interrupt_Manager.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/TIMER0/Timer0.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../MCAL/USART/USART.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../SERVICES/Delay.c")
set_source_files_properties(${Hema_default_default_XC8_FILE_TYPE_compile} PROPERTIES LANGUAGE C)
set(Hema_default_default_XC8_FILE_TYPE_link)
set(Hema_default_image_name "default.elf")
set(Hema_default_image_base_name "default")

# The output directory of the final image.
set(Hema_default_output_dir "${CMAKE_CURRENT_SOURCE_DIR}/../../../out/Hema")

# The full path to the final image.
set(Hema_default_full_path_to_image ${Hema_default_output_dir}/${Hema_default_image_name})

# Potential output file extensions
set(output_extensions
    .hex
    .hxl
    .mum
    .o
    .sdb
    .sym
    .cmf)
list(TRANSFORM output_extensions PREPEND "${Hema_default_output_dir}/${Hema_default_image_base_name}")
