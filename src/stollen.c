#include <stdlib.h>

#include "resources.h"
#include "stollen.h"
#include "dwarf.h"

#define MAX_MUSHROOMS 100

struct clan {
    Dwarfs_v dwarfs;
};
typedef struct clan* Clan;
typedef kvec_t(Clan) Clans_v;

struct stollen {
    int width;
    int height;
    int mushrooms;
    Clans_v clans;
    Object* map;
};

static void action       (Stollen, Dwarf, Action);
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
    this->mushrooms = 0;
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
    growMushrooms(this);
    for(int i=0; i<this->clans.n; i++) {
        Clan clan = this->clans.a[i];
        for(int i=0; i<clan->dwarfs.n; i++) {
            Dwarf d = clan->dwarfs.a[i];
            action(this, d, DwarfUpdate(d));
        }
    }
}

Object* StollenGetMap(Stollen this) {
    return this->map;
}

void StollenGetStats(Stollen this, char* buffer) {
    int n = 0;
    for(int i=0; i<this->clans.n; i++) {
        Clan clan = this->clans.a[i];
        for(int i=0; i<clan->dwarfs.n; i++) {
            Dwarf d = clan->dwarfs.a[i];
            n+= DwarfGetStats(d, &buffer[n]);
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


static void get(Stollen this, Dwarf dwarf) {
   Pos pos = DwarfGetPos(dwarf);
   Pos n = getNearObject(this, pos, MUSHROOM);
   if(n.x>=0) {
       this->map[n.x+n.y*this->width] = EMPTY;
       DwarfAddMushrooms(dwarf, rand()%3);
       this->mushrooms--;
   }
}
static void put(Stollen this, Dwarf dwarf) {}
static void fight(Stollen this, Dwarf dwarf) {}
static void dig(Stollen this, Dwarf dwarf) {
   Pos pos = DwarfGetPos(dwarf);
   Pos n = getNearObject(this, pos, ROCK);
   if(n.x>=0) {
       this->map[n.x+n.y*this->width] = EMPTY;
   }
}

static void action(Stollen this, Dwarf dwarf, Action action){
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
        case PUT:
            put(this, dwarf);
        case FIGHT:
            fight(this, dwarf);
            break;
        case DIG:
            dig(this, dwarf);
            break;
    }
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
    return (Pos){-1, -1};
}

static void growMushrooms(Stollen this) {
    while(this->mushrooms < MAX_MUSHROOMS) {
        Pos p = getEmptyCell(this);
        this->map[p.y*this->width+p.x] = MUSHROOM;
        this->mushrooms++;
    }
}
