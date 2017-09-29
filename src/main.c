#include "raylib.h"

#include "resources.h"
#include "stollen.h"

int main() {

    int screenWidth = 800;
    int screenHeight = 450;

    
    InitWindow(screenWidth, screenHeight, "Stollen");
    ResourcesInit();
    
    Stollen stollen = StollenNew(20, 20);
    StollenAddAI(stollen, 1);

    SetTargetFPS(60);
    while (!WindowShouldClose()) {

        StollenUpdate(stollen);
        
        BeginDrawing();
        {
            ClearBackground(BLACK);
            StollenDraw(stollen);
            DrawText("Stollen", 10, 10, 20, LIGHTGRAY);
            DrawFPS(screenWidth - 90, screenHeight - 30);  
        }
        EndDrawing();
    }

    CloseWindow();
    StollenFree(stollen);
    return 0;
}

