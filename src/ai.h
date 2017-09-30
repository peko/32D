#pragma once

#include "dwarf.h"

// http://c-faq.com/decl/recurfuncp.html
typedef struct dwarfState DwarfState;
struct dwarfState {
    DwarfAction action;
    DwarfState (*update)(DwarfEvents);
};

DwarfState StateStart();
DwarfState StateUpdate(DwarfState, DwarfEvents);
