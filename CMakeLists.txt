
cmake_minimum_required(VERSION 3.0)

project(Stollen)

include(./utils.cmake)
add_subdirectory(dep/raylib/src)
include_directories(dep/raylib/src)
add_executable(Stollen src/main.c src/stollen.c src/dwarf.c)
link_with_raylib(Stollen)
