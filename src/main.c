#include "raylib.h"

#include "stollen.h"

int main() {

    int screenWidth = 800;
    int screenHeight = 450;

    Stollen stollen = StollenNew(200, 200);
    
    InitWindow(screenWidth, screenHeight, "Stollen");

    Texture2D sprites = LoadTexture("../img/sprites.png");
    
    SetTargetFPS(60);
    while (!WindowShouldClose()) {
        BeginDrawing();
        {
            ClearBackground(BLACK);
            DrawTextureRec(sprites,(Rectangle){32,16,16,16}, (Vector2){128,64}, WHITE);
            DrawText("Stollen", 10, 10, 20, LIGHTGRAY);
            DrawFPS(screenWidth - 90, screenHeight - 30);  
        }
        EndDrawing();
    }

    CloseWindow();
    StollenFree(stollen);
    return 0;
}

