#pragma once

#include "types.h"

typedef struct stollen* Stollen;

Stollen StollenNew(int w, int h);
void StollenFree(Stollen);

void StollenAddAI(Stollen, int dwarfs_cnt);
void StollenUpdate(Stollen);
void StollenDraw(Stollen);
Object* StollenGetMap(Stollen);
