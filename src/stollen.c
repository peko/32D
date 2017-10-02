#include <stdlib.h>

#include "raylib.h"
#include "resources.h"
#include "stollen.h"
#include "dwarf.h"

#define MAX_MUSHROOMS 20

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
} Object;

struct stollen {
    int width;
    int height;
    int mushroomCnt;
    Clans_v clans;
    Object* map;
};

static void draw         (Object, Pos);
static void action       (Stollen, Dwarf, DwarfAction);
static void growMushrooms(Stollen);
static Pos  getEmptyCell (Stollen);

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
    this->mushroomCnt = 0;
    this->map = calloc(width*height, sizeof(int));
    for(int i=0; i<width*height; i++) {
        this->map[i] = rand()%100>90 ? ROCK : EMPTY;
    }
    growMushrooms(this);
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
        Pos p = getEmptyCell(this);
        if(p.x >= 0) {
            Dwarf dwarf = DwarfNew(p);
            this->map[p.y*this->width+p.x] = DWARF; 
            kv_push(Dwarf, clan->dwarfs, dwarf);
        }
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

static Pos getNearObject(Stollen this, Pos p, Object type) {
    if(this->map[(p.x+0)+(p.y-1)*this->width] == type) return (Pos){p.x+0,p.y-1}; // N
    if(this->map[(p.x+1)+(p.y+0)*this->width] == type) return (Pos){p.x+1,p.y+0}; // E
    if(this->map[(p.x+0)+(p.y+1)*this->width] == type) return (Pos){p.x+0,p.y+1}; // S
    if(this->map[(p.x-1)+(p.y+0)*this->width] == type) return (Pos){p.x-1,p.y+0}; // W
    return (Pos){-1,-1};
}

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
   Object* dm = &this->map[d.y * this->width + d.x];
   Object* tm = &this->map[t.y * this->width + t.x];
   if(*tm == EMPTY) {
       DwarfSetPos(dwarf, t);
       *tm = DWARF;
       *dm = EMPTY;
   }
}

/*
static void eat(Stollen this, Dwarf dwarf) {
    Pos d = DwarfGetPos(dwarf);
    Pos n = getNearObject(this, d, MUSHROOM);
    if(n.x>=0) {
       this->map[n.x+n.y*this->width] = EMPTY;
       DwarfEat(dwarf, 20);
    }
}
*/

static void get(Stollen this, Dwarf dwarf) {}
static void fight(Stollen this, Dwarf dwarf) {}
static void dig(Stollen this, Dwarf dwarf) {
   Pos d = DwarfGetPos(dwarf);
   Pos n = getNearObject(this, d, ROCK);
   if(n.x>=0) {
       this->map[n.x+n.y*this->width] = EMPTY;
   }
}

static void action(Stollen this, Dwarf dwarf, DwarfAction action){
    switch(action) {
        case NONE: break;
        case REST: break;
        case EAT:  break;
        case N:
        case E:
        case S:
        case W:
            move(this, dwarf, action-N);
            break;
        case GET:
            get(this, dwarf);
            break;
        case FIGHT:
            fight(this, dwarf);
            break;
        case DIG:
            dig(this, dwarf);
            break;
    }
}

static void draw(Object sprite, Pos pos) {
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

static Pos getEmptyCell(Stollen this) {
    // try random some times
    for(int i=0; i<100; i++) {
        Pos p = {rand() % this->width, rand() % this->height};
        if (this->map[p.y*this->width+p.x] == EMPTY) return p;
    }
    // Full iteration line by line 
    for(int y=0; y<this->height; y++) {
        for(int x=0; x<this->width; x++) {
            if(this->map[y*this->width+x] == EMPTY) return (Pos){x,y}; 
        }
    }
    // can not find empty cell
    return (Pos){-1,-1};
}

static void growMushrooms(Stollen this) {
    while(this->mushroomCnt < MAX_MUSHROOMS) {
        Pos p = getEmptyCell(this);
        this->map[p.y*this->width+p.x] = MUSHROOM;
        this->mushroomCnt++;
    }
}
