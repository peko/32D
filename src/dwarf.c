#include <stdlib.h>

#include "dwarf.h"
#include "ai.h"

struct Dwarf {
    int x, y;
    int dir;
    int health;
    int energy;
    int satiety;
    DwarfState state;
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

// forward declaration for static helpers
static unsigned int enemyDistance(Dwarf his);
static unsigned int getEvents(Dwarf this);


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
    this->state = StateUpdate(this->state, getEvents(this));

    this->health  += actionCosts[this->state.action][0];
    this->energy  += actionCosts[this->state.action][1];
    this->satiety += actionCosts[this->state.action][2];

    if(this->satiety < 0) this->health += this->satiety/10;
    
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


// Static functions

static DwarfEvents getEvents(Dwarf this) {
    DwarfEvents events = 0;
  
    if (this->health > 0)  events |= ALIVE;
    else                   events |= DEAD;

    if (this->health  < 20) events |= WOUNDED;
    if (this->health  > 80) events |= HEALTHY;
    if (this->satiety > 80) events |= FULL;
    if (this->satiety < 20) events |= HUNGRY;
    if (this->energy  < 20) events |= TIRED;
    if (this->energy  > 80) events |= RESTED;
    
    if (enemyDistance(this) < 10) events |= ENEMY_NEAR;
    if (enemyDistance(this) > 20) events |= NO_ENEMIES;

    if (events & (ENEMY_NEAR|WOUNDED)) events |= UNDER_THREAT;
    else                               events |= CALM;

    return events;
}

static unsigned int enemyDistance(Dwarf this) {
    return 10;
}
