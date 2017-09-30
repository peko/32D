#include <stdlib.h>

#include "dwarf.h"
#include "ai.h"

struct Dwarf {
    float x, y;
    float dir;
    float health;
    float energy;
    float satiety;
    State state;
};

Dwarf DwarfNew() {
    Dwarf this = calloc(1, sizeof(struct Dwarf));
    this->state = StateStart();
    return this;
}

void DwarfFree(Dwarf this) {
    free(this);
}

void DwarfUpdate(Dwarf this) {
    this->state = StateUpdate(this->state, this); 
}


