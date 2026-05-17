include("${CMAKE_CURRENT_LIST_DIR}/rule.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/file.cmake")

set(Hema_default_library_list )

# Handle files with suffix (s|as|asm|AS|ASM|As|aS|Asm), for group default-XC8
if(Hema_default_default_XC8_FILE_TYPE_assemble)
add_library(Hema_default_default_XC8_assemble OBJECT ${Hema_default_default_XC8_FILE_TYPE_assemble})
    Hema_default_default_XC8_assemble_rule(Hema_default_default_XC8_assemble)
    list(APPEND Hema_default_library_list "$<TARGET_OBJECTS:Hema_default_default_XC8_assemble>")

endif()

# Handle files with suffix S, for group default-XC8
if(Hema_default_default_XC8_FILE_TYPE_assemblePreprocess)
add_library(Hema_default_default_XC8_assemblePreprocess OBJECT ${Hema_default_default_XC8_FILE_TYPE_assemblePreprocess})
    Hema_default_default_XC8_assemblePreprocess_rule(Hema_default_default_XC8_assemblePreprocess)
    list(APPEND Hema_default_library_list "$<TARGET_OBJECTS:Hema_default_default_XC8_assemblePreprocess>")

endif()

# Handle files with suffix [cC], for group default-XC8
if(Hema_default_default_XC8_FILE_TYPE_compile)
add_library(Hema_default_default_XC8_compile OBJECT ${Hema_default_default_XC8_FILE_TYPE_compile})
    Hema_default_default_XC8_compile_rule(Hema_default_default_XC8_compile)
    list(APPEND Hema_default_library_list "$<TARGET_OBJECTS:Hema_default_default_XC8_compile>")

endif()


# Main target for this project
add_executable(Hema_default_image_Uusundml ${Hema_default_library_list})

set_target_properties(Hema_default_image_Uusundml PROPERTIES
    OUTPUT_NAME "default"
    SUFFIX ".elf"
    ADDITIONAL_CLEAN_FILES "${output_extensions}"
    RUNTIME_OUTPUT_DIRECTORY "${Hema_default_output_dir}")
target_link_libraries(Hema_default_image_Uusundml PRIVATE ${Hema_default_default_XC8_FILE_TYPE_link})

# Add the link options from the rule file.
Hema_default_link_rule( Hema_default_image_Uusundml)


