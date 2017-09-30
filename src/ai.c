#include <stdio.h>

#include "ai.h"

State rest(Dwarf);
State eat (Dwarf);

State StateStart() {
    State s = {REST, rest};
    return s;
}

State StateUpdate(State state, Dwarf dwarf) {
    State s = (*state.update)(dwarf);
    return s;
}

State rest(Dwarf dwarf) {
    State s = {EAT, eat};
    return s;
}

State eat(Dwarf dwarf) {
    State s = {REST, rest};
    return s;
}

