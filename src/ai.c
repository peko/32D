#include <stdio.h>

#include "ai.h"

// State alive(DwarfEvents);
// State dead (DwarfEvents);

static DwarfState rest   (DwarfEvents);
static DwarfState eat    (DwarfEvents);
static DwarfState harvest(DwarfEvents);
static DwarfState fight  (DwarfEvents);
static DwarfState avoid  (DwarfEvents);

DwarfState StateStart() {
    DwarfState s = (DwarfState){REST, rest};
    return s;
}

DwarfState StateUpdate(DwarfState state, DwarfEvents events) {
    DwarfState s = (*state.update)(events);
    s.action = rand() % DIG;
    return s;
}


// States

DwarfState rest(DwarfEvents e) {
    if(e & HUNGRY) return (DwarfState){EAT, eat};
    return (DwarfState){REST, rest};
}

DwarfState eat(DwarfEvents e) {
    if(e & FULL) return (DwarfState){REST, rest};
    return (DwarfState){EAT, eat};
}

DwarfState harvest(DwarfEvents e) {
    return (DwarfState){HARVEST, harvest};
}

DwarfState avoid(DwarfEvents e) {
    return (DwarfState){FIGHT, avoid};
}

DwarfState fight(DwarfEvents e) {
    return (DwarfState){FIGHT, fight};
}
