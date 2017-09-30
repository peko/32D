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
    if(DwarfSatiety(dwarf) < 20) return (State){EAT, eat};
    return (State){REST, rest};
}

State eat(Dwarf dwarf) {
    if(DwarfSatiety(dwarf) >= 100) return (State){REST, rest};
    return (State){EAT, eat};
}

