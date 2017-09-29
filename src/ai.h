#pragma once

#include "dwarf.h"

typedef struct state State;
struct state {
    DwarfAction action;
    State (*update)(Dwarf);
};

State StateStart();
State StateUpdate(State, Dwarf);
