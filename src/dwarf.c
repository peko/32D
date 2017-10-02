#include <stdlib.h>
#include <stdio.h>

#include "dwarf.h"
#include "ai.h"

struct Dwarf {
    Pos pos;
    int health;
    int energy;
    int satiety;
    int mushrooms;
    Ai  ai;
};

static int actionCosts[][3] = {
    { 0, 0,-1}, // NONE
    {10,10,-1}, // REST
    { 0, 0,-1}, // EAT
    {-1,-1,-1}, // N
    {-1,-1,-1}, // E
    {-1,-1,-1}, // S
    {-1,-1,-1}, // W
    {-5,-5,-5}, // FIGHT
    {-5,-5,-5}, // DIG
};

// forward declaration for static helpers
static unsigned int enemyDistance(Dwarf his);
static unsigned int getEvents(Dwarf this);

Dwarf DwarfNew(Pos pos) {
    Dwarf this = calloc(1, sizeof(struct Dwarf));
    this->ai          = AiNew();
    this->pos         = pos;
    this->health      = 100;
    this->energy      = 100;
    this->satiety     = 100;
    this->mushrooms =   3;
    return this;
}

void DwarfFree(Dwarf this) {
    AiFree(this->ai);
    free(this);
}

Action DwarfUpdate(Dwarf this) {
    
    // State machine update

    Action action = AiUpdate(this->ai, getEvents(this));

    this->health  += actionCosts[action][0];
    this->energy  += actionCosts[action][1];
    this->satiety += actionCosts[action][2];

    if(this->satiety < 0) this->health += this->satiety/10;
    if(action == EAT) {
        if (this->mushrooms > 0) { 
            this->satiety += 100; 
            this->mushrooms--;
            action = NONE;
        }
        action = GET;
    }

    // limit values
    if(this->health  > 100) this->health  = 100;
    if(this->energy  > 100) this->energy  = 100;
    if(this->satiety > 100) this->satiety = 100;
    
    if(this->health  <   0) this->health  =   0;
    if(this->energy  <   0) this->energy  =   0;
    if(this->satiety < -20) this->satiety = -20;

    static const char* actionNames[] = {
        "None",
        "Resting",
        "Eating",
        "Getting", "Putting",
        "N","E","S","W",
        "Fighting",
        "Digging",
    };
    printf("%4d %4d %4d : %3d %3d %3d : (%d) %s\n", 
        this->health, this->energy, this->satiety,
        actionCosts[action][0], actionCosts[action][1], actionCosts[action][2],
        action, actionNames[action]);

    return action;
}

float DwarfSatiety(Dwarf this) {
    return this->satiety;
}

Pos DwarfGetPos(Dwarf this) {
    return this->pos;
}

void DwarfSetPos(Dwarf this, Pos pos) {
    this->pos = pos;
}

void DwarfEat(Dwarf this, int sat) {
    this->satiety += sat;
}

void DwarfAddMushrooms(Dwarf this, int cnt) {
    this->mushrooms += cnt;
    if(this->mushrooms < 0) this->mushrooms = 0;
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
    
    if (this->mushrooms == 0) events |= NO_FOOD;
    if (this->mushrooms >= 1) events |= ENOUGH_FOOD;

    if (enemyDistance(this) < 10) events |= ENEMY_NEAR;
    if (enemyDistance(this) > 20) events |= NO_ENEMIES;

    if (events & (ENEMY_NEAR|WOUNDED)) events |= UNDER_THREAT;
    else                               events |= CALM;

    return events;
}

static unsigned int enemyDistance(Dwarf this) {
    return 10;
}
