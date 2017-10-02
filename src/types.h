#pragma once

typedef struct {int x, y;} Pos;

typedef enum {
    EMPTY,
    ROCK,
    MUSHROOM,
    DWARF
} Object;

typedef enum {
    NONE,
    REST,
    EAT,
    GET, PUT,
    N, E, S, W,
    FIGHT,
    DIG
} Action;

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
    NO_FOOD      = 1 << 13,
    ENOUGH_FOOD  = 1 << 14,
};
typedef unsigned int DwarfEvents;
