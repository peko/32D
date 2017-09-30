#pragma once

#include "dwarf.h"

// http://c-faq.com/decl/recurfuncp.html
typedef struct state State;
struct state {
    DwarfAction action;
    State (*update)(Dwarf);
};

State StateStart();
State StateUpdate(State, Dwarf);
