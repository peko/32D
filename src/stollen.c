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

typedef enum {
    EMPTY,
    ROCK,
    MUSHROOM,
    DWARF
} Sprite;

struct stollen {
    int width;
    int height;
    Clans_v clans;
    Sprite* map;
};

static void action(Stollen, Dwarf, DwarfAction);
static void draw(Sprite, Pos);

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

Stollen StollenNew(int width, int height) {
    Stollen this = calloc(1, sizeof(struct stollen));
    kv_init(this->clans);
    this->width  = width;
    this->height = height;
    this->map = calloc(width*height, sizeof(int));
    for(int i=0; i<width*height; i++) {
        this->map[i] = rand()%100>90 ? ROCK : EMPTY;
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
        Pos pos = {rand()%this->width, rand()%this->height};
        Dwarf dwarf = DwarfNew(pos);
        this->map[pos.y * this->width + pos.x] = DWARF; 
        kv_push(Dwarf, clan->dwarfs, dwarf);
    }
}

void StollenUpdate(Stollen this) {
    for(int i=0; i<this->clans.n; i++) {
        Clan clan = this->clans.a[i];
        for(int i=0; i<clan->dwarfs.n; i++) {
            Dwarf d = clan->dwarfs.a[i];
            action(this, d, DwarfUpdate(d));
        }
    }
}

void StollenDraw(Stollen this) {
    for(int y=0; y<this->height; y++) {
        for(int x=0; x<this->width; x++) {
            draw(this->map[y*this->width+x], (Pos){x,y});
        }
    }
}

// Static

// Cell offset            N      E     S      W
static Pos offsets[] = {{0,-1},{1,0},{0,1},{-1,0}};
static void move(Stollen this, Dwarf dwarf, int dir) {
   Pos d = DwarfGetPos(dwarf);
   Pos o = offsets[dir];
   Pos t = {d.x+o.x, d.y+o.y};

   if (t.x<0) t.x += this->width;
   if (t.y<0) t.y += this->height;
   if (t.x>this->width ) t.x %= this->width;
   if (t.y>this->height) t.y %= this->height;
   Sprite* dm = &this->map[d.y * this->width + d.x];
   Sprite* tm = &this->map[t.y * this->width + t.x];
   if(*tm == EMPTY) {
       DwarfSetPos(dwarf, t);
       *tm = DWARF;
       *dm = EMPTY;
   }
}
static void eat(Stollen this, Dwarf dwarf) {}
static void harvest(Stollen this, Dwarf dwarf) {}
static void fight(Stollen this, Dwarf dwarf) {}
static void dig(Stollen this, Dwarf dwarf) {}

static void action(Stollen this, Dwarf dwarf, DwarfAction action){
    switch(action) {
        case REST: break;
        case EAT:
            eat(this, dwarf);
        case N:
        case E:
        case S:
        case W:
            move(this, dwarf, action-N);
            break;
        case HARVEST:
            harvest(this, dwarf);
            break;
        case FIGHT:
            fight(this, dwarf);
            break;
        case DIG:
            dig(this, dwarf);
            break;
    }
}

static void draw(Sprite sprite, Pos pos) {
    Rectangle src;
    switch(sprite) {
        case EMPTY:
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
    DrawTextureRec(sprites, src, (Vector2){pos.x*16, pos.y*16}, WHITE);
}

