#include <stdio.h>

#include "ai.h"

// completting type
struct dwarfState {
    DwarfAction action;
    void (*update)(DwarfState, DwarfEvents);
};

// Forward declaration of states
static void eat    (DwarfState, DwarfEvents);
static void dead   (DwarfState, DwarfEvents);
static void rest   (DwarfState, DwarfEvents);
static void fight  (DwarfState, DwarfEvents);
static void avoid  (DwarfState, DwarfEvents);
static void harvest(DwarfState, DwarfEvents);

#define GOTO(action, state) (*this=(struct dwarfState){(action),(state)})

DwarfState StateNew() {
    DwarfState this = calloc(1, sizeof(struct dwarfState));
    GOTO(NONE, rest);
    return this;
}

void StateFree(DwarfState this){
    free(this);
}

void StateUpdate(DwarfState this, DwarfEvents events) {
    (*this->update)(this, events);
}

DwarfAction StateAction(DwarfState this) {
    return this->action;
} 

// Static

static void dead(DwarfState this, DwarfEvents e) {
}

static void rest(DwarfState this, DwarfEvents e) {
    if(e & HUNGRY) GOTO(EAT, eat);
}

static void eat(DwarfState this, DwarfEvents e) {
    if(e & FULL) GOTO(REST, rest);
}

static void harvest(DwarfState this, DwarfEvents e) {
}

static void avoid(DwarfState this, DwarfEvents e) {
}

static void fight(DwarfState this, DwarfEvents e) {
}
