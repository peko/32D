#pragma once

#include "dwarf.h"

typedef struct ai* Ai;
Ai AiNew();
void AiFree(Ai);

DwarfAction AiUpdate(Ai, DwarfEvents);
