#include "raylib.h"

#include "resources.h"
#include "stollen.h"

int stollenWidth  = 32;
int stollenHeight = 32;
int screenWidth  = 32*16+256;
int screenHeight = 32*16;

static void stollenDraw(Stollen);
static void objectDraw(Object, Pos);
static void statsDraw(Stollen);
int main() {

    InitWindow(screenWidth, screenHeight, "Stollen");
    ResourcesInit();
    
    Stollen stollen = StollenNew(stollenWidth, stollenHeight);
    StollenAddAI(stollen, 1);

    SetTargetFPS(30);
    while (!WindowShouldClose()) {
        
        // if(++i%10==0) 
        StollenUpdate(stollen);
        
        BeginDrawing();
        {
            ClearBackground(BLACK);
            stollenDraw(stollen);
            statsDraw(stollen);
            DrawText("Stollen", 8, 8, 20, LIGHTGRAY);
            DrawFPS(screenWidth - 88, screenHeight - 28);  
        }
        EndDrawing();
    }

    CloseWindow();
    StollenFree(stollen);
    return 0;
}

static void stollenDraw(Stollen stollen) {
    Object* map = StollenGetMap(stollen);
    for(int y=0; y<stollenHeight; y++) {
        for(int x=0; x<stollenHeight; x++) {
            objectDraw(map[y*stollenWidth + x], (Pos){x,y});
        }
    }
}

static void objectDraw(Object sprite, Pos pos) {
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

static void statsDraw(Stollen stollen) {
    static char buffer[1024];
    StollenGetStats(stollen, buffer);
    // DrawText(buffer, 32*16+8, 8, 10, LIGHTGRAY);
    DrawTextEx(font, buffer, (Vector2){32*16+8, 8}, font.baseSize, 1, LIGHTGRAY);
}
