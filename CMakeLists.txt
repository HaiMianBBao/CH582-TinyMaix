cmake_minimum_required(VERSION 3.15)

# add_subdirectory(${CHIP}_drivers)
# mcu drivers
file(GLOB_RECURSE mcu_sources
"${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/StdPeriphDriver/*.c"
"${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/RVMSIS/*.c"
"${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/Startup/startup_CH583.S"
)

list(REMOVE_ITEM mcu_sources
    "${CMAKE_CURRENT_LIST_DIR}/drv/${CHIP}_drivers/StdPeriphDriver/CH58x_usbdev.c"
    "${CMAKE_CURRENT_LIST_DIR}/drv/${CHIP}_drivers/StdPeriphDriver/CH58x_usb2dev.c"
    "${CMAKE_CURRENT_LIST_DIR}/drv/${CHIP}_drivers/StdPeriphDriver/CH58x_usbhostBase.c"
    "${CMAKE_CURRENT_LIST_DIR}/drv/${CHIP}_drivers/StdPeriphDriver/CH58x_usbhostClass.c"
)

list(APPEND ADD_SRCS  ${mcu_sources})

sdk_generate_library()
sdk_add_link_libraries(${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/StdPeriphDriver/libISP583.a)


file(GLOB_RECURSE tinymaix_sources
"${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/tm_layers_O1.c"
"${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/tm_layers.c"
"${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/tm_model.c"
"${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/tm_stat.c"
)

list(APPEND ADD_SRCS  ${tinymaix_sources})


#添加源文件参与编译
sdk_library_add_sources(${ADD_SRCS})

sdk_add_include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/StdPeriphDriver/inc
    ${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/RVMSIS
    ${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/HAL/include
    ${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/LIB
)

sdk_add_include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/include
    ${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/model/cifar
    ${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/model/mbnet
    ${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/model/mnist
    ${CMAKE_CURRENT_SOURCE_DIR}/TinyMaix/model/vww96
)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_C_STANDARD 99)

# sdk_add_compile_definitions(BFLB_USE_HAL_DRIVER ARCH_RISCV BFLB_USE_ROM_DRIVER)
# add_definitions(-DCH58x_DEBUG=0)
sdk_add_compile_definitions(-DDEBUG=1)
sdk_add_compile_options(-march=rv32imac -mabi=ilp32 -mcmodel=medany -msmall-data-limit=8 -mno-save-restore -std=gnu99)
sdk_add_compile_options(-fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -g)
sdk_add_compile_options(-O3)

sdk_set_linker_script(${CMAKE_CURRENT_SOURCE_DIR}/drv/${CHIP}_drivers/Ld/Link.ld)

# set(LINKER_SCRIPT  ${CMAKE_CURRENT_SOURCE_DIR}/Ld/Link.ld)
sdk_add_link_options(-nostartfiles
                -Xlinker --gc-sections  
                -Wl,--print-memory-usage 
                -Wl,-Map,${PROJECT_NAME}.map 
                # --specs=nano.specs 
                --specs=nosys.specs)