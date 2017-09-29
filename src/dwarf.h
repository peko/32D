#pragma once

#include "kvec.h"

typedef struct Dwarf* Dwarf;
typedef kvec_t(Dwarf) Dwarfs_v;

typedef enum {
    REST,
    EAT,
    N, E, S, W,
    FIGHT,
    DIG
} DwarfAction;

Dwarf DwarfNew();
void DwarfFree(Dwarf);
void DwarfUpdate(Dwarf);
