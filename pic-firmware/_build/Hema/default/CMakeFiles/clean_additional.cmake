# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "E:\\temp_xc8\\pic-firmware\\out\\Hema\\default.cmf"
  "E:\\temp_xc8\\pic-firmware\\out\\Hema\\default.hex"
  "E:\\temp_xc8\\pic-firmware\\out\\Hema\\default.hxl"
  "E:\\temp_xc8\\pic-firmware\\out\\Hema\\default.mum"
  "E:\\temp_xc8\\pic-firmware\\out\\Hema\\default.o"
  "E:\\temp_xc8\\pic-firmware\\out\\Hema\\default.sdb"
  "E:\\temp_xc8\\pic-firmware\\out\\Hema\\default.sym"
  )
endif()
