macro(sdk_generate_library)
  get_filename_component(library_name ${CMAKE_CURRENT_LIST_DIR} NAME)
  message(STATUS "[register library : ${library_name}], path:${CMAKE_CURRENT_LIST_DIR}")

  set(CURRENT_STATIC_LIBRARY ${library_name})
  add_library(${library_name} STATIC)
  set_property(GLOBAL APPEND PROPERTY SDK_LIBS ${library_name})
  target_link_libraries(${library_name} PUBLIC sdk_intf_lib)
endmacro()

macro(app_generate_library)
  get_filename_component(library_name ${CMAKE_CURRENT_LIST_DIR} NAME)
  message(STATUS "[register library : ${library_name}], path:${CMAKE_CURRENT_LIST_DIR}")

  set(CURRENT_STATIC_LIBRARY ${library_name})
  add_library(${library_name} STATIC)
  set_property(GLOBAL APPEND PROPERTY SDK_LIBS ${library_name})
  target_link_libraries(${library_name} PUBLIC app_lib)
endmacro()


function(sdk_library_add_sources)
  foreach(arg ${ARGV})
    if(IS_DIRECTORY ${arg})
    message(FATAL_ERROR "sdk_library_add_sources() was called on a directory")
    endif()

    if(IS_ABSOLUTE ${arg})
    set(path ${arg})
    else()
    set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_sources(${CURRENT_STATIC_LIBRARY} PRIVATE ${path})
  endforeach()
endfunction()

function(app_library_add_sources)
  foreach(arg ${ARGV})
    if(IS_DIRECTORY ${arg})
    message(FATAL_ERROR "sdk_library_add_sources() was called on a directory")
    endif()

    if(IS_ABSOLUTE ${arg})
    set(path ${arg})
    else()
    set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_sources(${CURRENT_STATIC_LIBRARY} PRIVATE ${path})
  endforeach()
endfunction()

function(sdk_library_add_sources_ifdef feature)
  if(${${feature}})
  sdk_library_add_sources(${ARGN})
  endif()
endfunction()

function(sdk_add_include_directories)
  foreach(arg ${ARGV})
    if(IS_ABSOLUTE ${arg})
      set(path ${arg})
    else()
      set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_include_directories(sdk_intf_lib INTERFACE ${path})
  endforeach()
endfunction()

function(app_add_include_directories)
  foreach(arg ${ARGV})
    if(IS_ABSOLUTE ${arg})
      set(path ${arg})
    else()
      set(path ${CMAKE_CURRENT_SOURCE_DIR}/${arg})
    endif()
    target_include_directories(app_lib INTERFACE ${path})
  endforeach()
endfunction()


function(sdk_add_include_directories_ifdef feature)
  if(${${feature}})
  sdk_add_include_directories(${ARGN})
  endif()
endfunction()

function(sdk_add_compile_definitions)
  target_compile_definitions(sdk_intf_lib INTERFACE ${ARGV})
endfunction()

function(sdk_add_compile_definitions_ifdef feature)
if(${${feature}})
  target_compile_definitions(sdk_intf_lib INTERFACE ${ARGV})
endif()
endfunction()

function(sdk_add_compile_definitions_ifdef feature)
  if(${${feature}})
  sdk_add_compile_definitions(${ARGN})
  endif()
endfunction()

function(sdk_add_compile_options)
  target_compile_options(sdk_intf_lib INTERFACE ${ARGV})
endfunction()

function(sdk_add_compile_options_ifdef feature)
  if(${${feature}})
  sdk_add_compile_options(${ARGN})
  endif()
endfunction()

function(sdk_add_link_options)
  target_link_options(sdk_intf_lib INTERFACE ${ARGV})
endfunction()

function(sdk_add_link_options_ifdef feature)
  if(${${feature}})
  sdk_add_link_options(${ARGN})
  endif()
endfunction()

function(sdk_add_link_libraries)
  target_link_libraries(sdk_intf_lib INTERFACE ${ARGV})
endfunction()

function(sdk_add_link_libraries_ifdef feature)
  if(${${feature}})
  sdk_add_link_libraries(${ARGN})
  endif()
endfunction()

function(sdk_add_subdirectory_ifdef feature dir)
  if(${${feature}})
    add_subdirectory(${dir})
  endif()
endfunction()

function(sdk_set_linker_script ld)
  if(IS_ABSOLUTE ${ld})
  set(path ${ld})
  else()
  set(path ${CMAKE_CURRENT_SOURCE_DIR}/${ld})
  endif()
  set_property(GLOBAL PROPERTY LINKER_SCRIPT ${path})
endfunction()

function(search_application component_path)

if(DEFINED APP)

    # find CMakeLists in ${component_path}/${APP}/,${APP} is the first directory
    file(GLOB_RECURSE first_dir_cmakelists ${component_path}/${APP}/CMakeLists.txt)

    if(first_dir_cmakelists)
    list(APPEND cmakelists_files ${first_dir_cmakelists})
    endif()

    # find CMakeLists in ${component_path}/*/${APP}*/,${APP} is the second directory
    file(GLOB_RECURSE second_dir_cmakelists ${component_path}/*/${APP}*/CMakeLists.txt)

    if(second_dir_cmakelists)
    list(APPEND cmakelists_files ${second_dir_cmakelists})
    endif()

    list(REMOVE_DUPLICATES cmakelists_files)

    if(cmakelists_files)
        #build app finding
        foreach(cmakelists_file IN LISTS cmakelists_files)
        get_filename_component(app_absolute_dir ${cmakelists_file} DIRECTORY)
        get_filename_component(app_absolute_dir_name ${app_absolute_dir} NAME)
        message(STATUS "[run app:${app_absolute_dir_name}], path:${app_absolute_dir}")
        add_subdirectory(${app_absolute_dir} ${PROJECT_BINARY_DIR}/samples/${app_absolute_dir_name})
        endforeach()
    else()
    message(FATAL_ERROR "can not find ${APP} in the first or second directory under the path:${component_path}")
    endif()

else()
add_subdirectory($ENV{PROJECT_DIR}/src src)
endif()

endfunction()

macro(sdk_set_main_file)
    if(IS_ABSOLUTE ${ARGV0})
    set(path ${ARGV0})
    else()
    set(path ${CMAKE_CURRENT_SOURCE_DIR}/${ARGV0})
    endif()
  set(CURRENT_MAIN_FILE ${path})
endmacro()

macro(project name)

  _project(${name} ASM C CXX)

  set(HEX_FILE ${build_dir}/${name}.hex)
  set(BIN_FILE ${build_dir}/${name}.bin)
  set(MAP_FILE ${build_dir}/${name}.map)
  set(ASM_FILE ${build_dir}/${name}.asm)

  add_executable(${name}.elf ${CURRENT_MAIN_FILE})
  target_link_libraries(${name}.elf sdk_intf_lib)
  get_property(LINKER_SCRIPT_PROPERTY GLOBAL PROPERTY LINKER_SCRIPT)
  if(EXISTS ${LINKER_SCRIPT_PROPERTY})
    set_target_properties(${name}.elf PROPERTIES LINK_FLAGS "-T${LINKER_SCRIPT_PROPERTY} -Wl,-Map=${MAP_FILE}")
    set_target_properties(${name}.elf PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT_PROPERTY})
  endif()

  get_property(SDK_LIBS_PROPERTY GLOBAL PROPERTY SDK_LIBS)
  # target_link_libraries(${name}.elf -Wl,--start-group ${SDK_LIBS_PROPERTY} app -Wl,--end-group)

  target_link_libraries(${name}.elf -Wl,--start-group ${SDK_LIBS_PROPERTY} -Wl,--end-group)

  add_custom_command(TARGET ${name}.elf POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${name}.elf> ${BIN_FILE}
  COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${name}.elf> ${HEX_FILE}
  COMMAND ${CMAKE_OBJDUMP} -d -S $<TARGET_FILE:${name}.elf> >${ASM_FILE}
  # COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${mainname}.elf> ${HEX_FILE}
  COMMAND ${SIZE} $<TARGET_FILE:${name}.elf>
  COMMENT "Generate ${BIN_FILE}\r\n")

endmacro()