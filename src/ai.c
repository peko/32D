#include <stdio.h>

#include "ai.h"

// http://c-faq.com/decl/recurfuncp.html
typedef struct dwarfState {
    Action (*update)(Ai, DwarfEvents);
} DwarfState;

struct ai {
   kvec_t(DwarfState) states;
};

// Forward declaration of states
static Action alive  (Ai, DwarfEvents);
static Action dead   (Ai, DwarfEvents);
static Action eat    (Ai, DwarfEvents);
static Action rest   (Ai, DwarfEvents);
static Action fight  (Ai, DwarfEvents);
static Action avoid  (Ai, DwarfEvents);
static Action harvest(Ai, DwarfEvents);

static inline void AiPush(Ai, DwarfState);
static inline void AiPop(Ai);
static inline DwarfState* AiCurrentState(Ai);

#define PUSH_STATE(state) AiPush(this,(DwarfState){state})
#define POP_STATE (AiPop(this))

Ai AiNew() {
    Ai this = calloc(1, sizeof(struct ai));
    kv_init(this->states);
    PUSH_STATE(alive);
    return this;
}

void AiFree(Ai this) {
   kv_destroy(this->states);
   free(this);
}

static inline void AiPush(Ai this, DwarfState state) {
    kv_push(DwarfState, this->states, state);
}

static inline void AiPop(Ai this) {
    if(this->states.n >= 0)this->states.n--;
}

static inline DwarfState* AiCurrentState(Ai this) {
    return &this->states.a[this->states.n-1];
}

Action AiUpdate(Ai this, DwarfEvents e) {
    if (this->states.n>0) {
        DwarfState* state = AiCurrentState(this);
        Action action = (*state->update)(this, e);
        return action;
    }
    return NONE;
}

// States

static Action alive(Ai this, DwarfEvents e) {
    printf("ALIVE\n");
    if(e & DEAD) {
        // clear stack
        this->states.n = 0;
        PUSH_STATE(dead);
    }

    if(e & HUNGRY) PUSH_STATE(eat);
    if(e & ENEMY_NEAR) rand()%2 ? PUSH_STATE(avoid) : PUSH_STATE(fight);
    if((e & TIRED) || (e & WOUNDED)) PUSH_STATE(rest);

    return NONE;
}

static Action dead(Ai this, DwarfEvents e) {
    printf("DEAD\n");
    return NONE;
}

static Action rest(Ai this, DwarfEvents e) {
    printf("REST\n");
    if ((e & RESTED) && (e & HEALTHY)) POP_STATE;
    return REST;
}

static Action eat(Ai this, DwarfEvents e) {
    printf("EAT\n");
    if(e & FULL) POP_STATE;
    if(e & NO_FOOD) PUSH_STATE(harvest);
    return EAT;
}

static Action harvest(Ai this, DwarfEvents e) {
    printf("HARVEST\n");
    if(e & ENOUGH_FOOD) POP_STATE;
    return rand()%2?GET:rand()%3?N:rand()%3?E:rand()%2?S:W;
}

static Action avoid(Ai this, DwarfEvents e) {
    printf("AVOID\n");
    if(NO_ENEMIES) POP_STATE;
    return rand()%2?N:rand()%2?E:rand()%2?S:W;
}

static Action fight(Ai this, DwarfEvents e) {
    printf("FIGHT\n");
    if(NO_ENEMIES) POP_STATE;
    return FIGHT;
}

/*
typedef struct {
   void* (*new)(),
   void  (*free)(void*),
   Action (*update)(void*, DwarfEvents);
} Ai;

Ai SfsmAi = {
    .new    = AiNew,
    .free   = AiFree,
    .update = AiUpdate,
}
*/
