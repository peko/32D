#include <stdio.h>
#include <unistd.h>
#include "stollen.h"

int stollenWidth  = 64;
int stollenHeight = 64;

static void stollenDraw(Stollen);

int main() {

    Stollen stollen = StollenNew(stollenWidth, stollenHeight);
    StollenAddAI(stollen, 20);
    int i = 0;
    while(i++ < 100000) {
       StollenUpdate(stollen);
       stollenDraw(stollen);
    }
    StollenFree(stollen);
    return 0;
}

#define clear() printf("\033[H\033[J")
#define gotoxy(x,y) printf("\033[%d;%dH", (y), (x))

#define RST  "\x1B[0m"
#define RED  "\x1B[31m"
#define GRN  "\x1B[32m"
#define YEL  "\x1B[33m"
#define BLU  "\x1B[34m"
#define MAG  "\x1B[35m"
#define CYN  "\x1B[36m"
#define WHT  "\x1B[37m"

static void stollenDraw(Stollen stollen) {
    clear();
    Object* map = StollenGetMap(stollen);
    for(int y=0; y<stollenHeight; y++) {
        gotoxy(0, y);
        for(int x=0; x<stollenWidth; x++) {
            switch(map[y*stollenWidth + x]) {
                case EMPTY   : printf(BLU"."RST); break;
                case ROCK    : printf(WHT"#"RST); break;
                case DWARF   : printf(GRN"@"RST); break;
                case MUSHROOM: printf(RED"t"RST); break;
            };
        }
    }
}

