#pragma once

#include "dwarf.h"

typedef struct ai* Ai;
Ai AiNew();
void AiFree(Ai);

Action AiUpdate(Ai, DwarfEvents);
