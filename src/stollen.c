#include <stdlib.h>

#include "stollen.h"

struct stollen {
    int width;
    int height;
    int* map;
};

Stollen StollenNew(int width, int height) {
    Stollen this = calloc(1, sizeof(struct stollen));
    this->width  = width;
    this->height = height;
    this->map    = calloc(width*height, sizeof(int));
    return this;
}

void StollenFree(Stollen this) {
    free(this->map);
    free(this);
}

void StollenUpdate(Stollen this) {

}
