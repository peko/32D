#include "raylib.h"

#include "resources.h"
#include "stollen.h"

int main() {

    int screenWidth  = 32*16;
    int screenHeight = 32*16;

    InitWindow(screenWidth, screenHeight, "Stollen");
    ResourcesInit();
    
    Stollen stollen = StollenNew(32, 32);
    StollenAddAI(stollen, 1);

    SetTargetFPS(60);
    while (!WindowShouldClose()) {

        StollenUpdate(stollen);
        
        BeginDrawing();
        {
            ClearBackground(BLACK);
            StollenDraw(stollen);
            DrawText("Stollen", 8, 8, 20, LIGHTGRAY);
            DrawFPS(screenWidth - 88, screenHeight - 28);  
        }
        EndDrawing();
    }

    CloseWindow();
    StollenFree(stollen);
    return 0;
}

