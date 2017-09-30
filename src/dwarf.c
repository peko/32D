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

static int actionCosts[][3] = {
    {10,10,-1}, // REST
    {-1,-1,20}, // EAT
    {-1,-1,-1}, // N
    {-1,-1,-1}, // E
    {-1,-1,-1}, // S
    {-1,-1,-1}, // W
    {-2,-2,-1}, // FIGHT
    {-2,-2,-1}, // DIG
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
    
    // State machine update
    this->state = StateUpdate(this->state, this);

    this->health  += actionCosts[this->state.action][0];
    this->energy  += actionCosts[this->state.action][1];
    this->satiety += actionCosts[this->state.action][2];

    if(this->satiety < 0) this->health += this->satiety/10.0f;
    
    // limit values
    if(this->health  > 100) this->health  = 100;
    if(this->energy  > 100) this->energy  = 100;
    if(this->satiety > 100) this->satiety = 100;
    
    if(this->health < 0) this->health = 0;
    if(this->energy < 0) this->energy = 0;
}

float DwarfSatiety(Dwarf this) {
    return this->satiety;
}
