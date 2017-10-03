
cmake_minimum_required(VERSION 3.0)

project(Stollen)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wno-long-long -pedantic -g -pg -no-pie")
include(./utils.cmake)
add_subdirectory(dep/raylib/src)
include_directories(dep/raylib/src dep/klib/)
add_executable(test_raylib
    src/test_raylib.c 
    src/resources.c 
    src/stollen.c 
    src/dwarf.c 
    src/sfsm_ai.c)
link_with_raylib(test_raylib)

add_executable(test_tty
    src/test_tty.c 
    src/stollen.c 
    src/dwarf.c 
    src/sfsm_ai.c)
