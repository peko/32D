#pragma once

#include "kvec.h"

typedef struct {int x, y;} Pos;

typedef struct Dwarf* Dwarf;
typedef kvec_t(Dwarf) Dwarfs_v;

typedef enum {
    REST,
    EAT,
    N, E, S, W,
    HARVEST,
    FIGHT,
    DIG
} DwarfAction;

enum DwarfEvent {
    ALIVE        = 1 <<  1,
    DEAD         = 1 <<  2,
    UNDER_THREAT = 1 <<  3,
    CALM         = 1 <<  4,
    ENEMY_NEAR   = 1 <<  5,
    NO_ENEMIES   = 1 <<  6,
    WOUNDED      = 1 <<  7,
    HEALTHY      = 1 <<  8,
    HUNGRY       = 1 <<  9,
    FULL         = 1 << 10,
    TIRED        = 1 << 11,
    RESTED       = 1 << 12,
};
typedef unsigned int DwarfEvents;

Dwarf DwarfNew(Pos pos);
void DwarfFree(Dwarf);
DwarfAction DwarfUpdate(Dwarf);
Pos DwarfGetPos(Dwarf);
void DwarfSetPos(Dwarf, Pos);
