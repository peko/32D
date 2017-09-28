#pragma once

typedef struct stollen* Stollen;

Stollen StollenNew(int w, int h);
void    StollenFree(Stollen);

void StollenUpdate();

