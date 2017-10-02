#pragma once

#include "kvec.h"
#include "types.h"

typedef struct Dwarf* Dwarf;
typedef kvec_t(Dwarf) Dwarfs_v;

Dwarf DwarfNew(Pos pos);
void DwarfFree(Dwarf);
Action DwarfUpdate(Dwarf);
Pos DwarfGetPos(Dwarf);
void DwarfSetPos(Dwarf, Pos);
void DwarfEat(Dwarf, int);
void DwarfAddMushrooms(Dwarf, int);
