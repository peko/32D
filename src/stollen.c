#include <stdlib.h>

#include "raylib.h"

#include "resources.h"
#include "stollen.h"
#include "dwarf.h"

struct clan {
    Dwarfs_v dwarfs;
};
typedef struct clan* Clan;
typedef kvec_t(Clan) Clans_v;

struct stollen {
    int width;
    int height;
    Clans_v clans;
    int* map;
};

typedef enum {
    GROUND,
    ROCK,
    MUSHROOM,
    DWARF
} Sprite;
static void draw(Sprite sprite, int x, int y );

Clan ClanNew() {
    Clan clan = calloc(1, sizeof(struct clan));
    kv_init(clan->dwarfs);
    return clan;
}

void ClanFree(Clan this) {
    for(int i=0; i<this->dwarfs.n; i++) {
        DwarfFree(this->dwarfs.a[i]);
    }
    kv_destroy(this->dwarfs);
}

void ClanUpdate(Clan this) {
    for(int i=0; i<this->dwarfs.n; i++) {
        DwarfUpdate(this->dwarfs.a[i]);
    }
}

Stollen StollenNew(int width, int height) {
    Stollen this = calloc(1, sizeof(struct stollen));
    kv_init(this->clans);
    this->width  = width;
    this->height = height;
    this->map = calloc(width*height, sizeof(int));
    for(int i=0; i<width*height; i++) {
        this->map[i] = rand()%2;
    }
    return this;
}

void StollenFree(Stollen this) {
    // Free dwarfs
    for(int i=0; i<this->clans.n; i++) {
        ClanFree(this->clans.a[i]);
    };
    kv_destroy(this->clans);
    
    free(this->map);
    free(this);
}

void StollenAddAI(Stollen this, int dwarfs_cnt) {
    Clan clan = ClanNew();
    kv_push(Clan, this->clans, clan);
    for(int i=0; i<dwarfs_cnt; i++) {
        Dwarf dwarf = DwarfNew();
        kv_push(Dwarf, clan->dwarfs, dwarf);
    }
}

void StollenUpdate(Stollen this) {
    for(int i=0; i<this->clans.n; i++) {
        ClanUpdate(this->clans.a[i]);
    }
}

void StollenDraw(Stollen this) {
    for(int y=0; y<this->height; y++) {
        for(int x=0; x<this->width; x++) {
            switch(this->map[y*this->width + x]) {
                case 0 : 
                    draw(GROUND, x, y);
                    break;
                case 1 : 
                    draw(ROCK  , x, y);
                    break;
            }
        }
    }
}


static void draw(Sprite sprite, int x, int y ) {
    Rectangle src;
    switch(sprite) {
        case GROUND:
            src = (Rectangle){32,32,16,16};
            break;
        case ROCK:
            src = (Rectangle){ 0,32,16,16};
            break;
        case MUSHROOM:
            src = (Rectangle){16,32,16,16};
            break;
        case DWARF:
            src = (Rectangle){32,16,16,16};
            break;
    }
    DrawTextureRec(sprites, src, (Vector2){x*16, y*16}, WHITE);
}
