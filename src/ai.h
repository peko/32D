#pragma once

#include "dwarf.h"

// http://c-faq.com/decl/recurfuncp.html
typedef struct dwarfState* DwarfState;

DwarfState StateNew();
void StateFree(DwarfState);

void StateUpdate(DwarfState, DwarfEvents);
DwarfAction StateAction(DwarfState);
