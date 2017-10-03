#include <stdio.h>

#include "kvec.h"
#include "types.h"

// http://c-faq.com/decl/recurfuncp.html
typedef struct StateStack* StateStack; 
typedef Action (*State)(StateStack, DwarfEvents);
struct StateStack {size_t n, m; State *a; };
typedef struct StateStack* StateStack;

static Action rest   (StateStack, DwarfEvents);
static Action eat    (StateStack, DwarfEvents);
static Action harvest(StateStack, DwarfEvents);
/*
// Forward declaration of states
static Action alive  (StateStack, DwarfEvents);
static Action dead   (StateStack, DwarfEvents);
static Action eat    (StateStack, DwarfEvents);
static Action fight  (StateStack, DwarfEvents);
static Action avoid  (StateStack, DwarfEvents);

static inline void push(Ai, State);
static inline void pop(Ai);
static inline State* currentState(Ai);
*/

#define PUSH(state) kv_push(State, *stack, state)
#define POP stack->n-- 

static void* _new() {
    StateStack stack = calloc(1, sizeof(struct StateStack));
    kv_init(*stack);
    PUSH(rest);
    return stack;
}

static void _free(void* this) {
    StateStack stack = this;
    kv_destroy(*stack);
    free(this);
}

static Action _update(void* this, DwarfEvents events) {
    StateStack stack = this;
    if(stack->n>0) {
        State currentState = stack->a[stack->n-1];
        Action action = (*currentState)(stack, events);
        return action;
    }
    printf("State Stack is empty!");
    return NONE;
}

static Action rest(StateStack stack, DwarfEvents e) {
    if(e & HUNGRY) PUSH(eat);
    return REST;
}

static Action eat(StateStack stack, DwarfEvents e) {
    if(e & FULL) POP;
    if(e & NO_FOOD) PUSH(harvest);
    return EAT;
}

static Action harvest(StateStack stack, DwarfEvents e) {
    if(e & ENOUGH_FOOD) POP;
    return rand()%2?GET:rand()%3?N:rand()%3?E:rand()%2?S:W;
}

/*
static inline void push(StateStack stack, State state) {
    kv_push(State, this->states, state);
}

static inline void pop(StateStack stack) {
    if(this->states.n >= 0)this->states.n--;
}

static inline State* currentState(StateStack stack) {
    return &this->states.a[this->states.n-1];
}


// States

static Action alive(StateStack stack, DwarfEvents e) {
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

static Action dead(StateStack stack, DwarfEvents e) {
    printf("DEAD\n");
    return NONE;
}




static Action avoid(StateStack stack, DwarfEvents e) {
    printf("AVOID\n");
    if(NO_ENEMIES) POP_STATE;
    return rand()%2?N:rand()%2?E:rand()%2?S:W;
}

static Action fight(StateStack stack, DwarfEvents e) {
    printf("FIGHT\n");
    if(NO_ENEMIES) POP_STATE;
    return FIGHT;
}
*/
Ai SfsmAi = {
    .new    = _new,
    .free   = _free,
    .update = _update,
};
