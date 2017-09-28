#include <stdlib.h>

#include "dwarf.h"

struct Dwarf {
    float x,y;
    float dir;
    float health;
    float energy;
    float satiety;
};

Dwarf DwarfNew() {
    Dwarf this = calloc(1, sizeof(struct Dwarf));
    return this;
}

void DwarfFree(Dwarf this) {
    free(this);
}
