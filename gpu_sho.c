#include "raylib.h"
#include "rlgl.h"
//#include <raymath.h>

#define NUM_SPRINGS 200

// square of distance between pts
#define DX_2 .5
// square of wave velocity
#define C_2 2.

#define SCREEN_WIDTH 1800
#define SCREEN_HEIGHT 1000

int main() {
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Simple Harmonic Oscillators");

    // compute shader
    char *compute_raw             = LoadFileText("sho_pde.glsl");
    unsigned int comp_shader      = rlLoadShader(compute_raw, RL_COMPUTE_SHADER);
    unsigned int prog_comp_shader = rlLoadShaderProgramCompute(comp_shader);
    UnloadFileText(compute_raw);

    // frag shader 
    Shader frag_shader      = LoadShader(0, "sho_pde.frag");
    //int resolution_unif_idx = GetShaderLocation(frag_shader, "resolution");

    // SSBOs
    unsigned int ssbo_prev = rlLoadShaderBuffer(SCREEN_WIDTH*SCREEN_HEIGHT*sizeof(float), 0, RL_DYNAMIC_COPY);
    unsigned int ssbo_curr = rlLoadShaderBuffer(SCREEN_WIDTH*SCREEN_HEIGHT*sizeof(float), 0, RL_DYNAMIC_COPY);
    unsigned int ssbo_next = rlLoadShaderBuffer(SCREEN_WIDTH*SCREEN_HEIGHT*sizeof(float), 0, RL_DYNAMIC_COPY);

    SetTargetFPS(60);

    Image white_img = GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, WHITE);
    Texture white_tex = LoadTextureFromImage(white_img);
    UnloadImage(white_img);

    while(!WindowShouldClose()) {                                   // GAME loop ----

        //double dt = GetFrameTime();

        // compute
        rlEnableShader(prog_comp_shader);
        rlBindShaderBuffer(ssbo_prev, 1);
        rlBindShaderBuffer(ssbo_curr, 2);
        rlBindShaderBuffer(ssbo_next, 3);
        rlComputeShaderDispatch(SCREEN_WIDTH/4, SCREEN_HEIGHT/4, 1);
        rlDisableShader();

        // roll buffers around
        int temp  = ssbo_prev;
        ssbo_prev = ssbo_curr;
        ssbo_curr = ssbo_next;
        ssbo_next = temp;

        rlBindShaderBuffer(ssbo_curr, 1);
        //setShaderValue(frag_shader, resolution_unif_idx, &resolution, SHADER_UNIFORM_VEC2);

        BeginDrawing();                                             // DRAW stage ---

            ClearBackground(BLACK);

            BeginShaderMode(frag_shader);
                DrawTexture(white_tex, 0, 0, WHITE);
            EndShaderMode();

        EndDrawing();

    }                                                               // cleanup ------

    rlUnloadShaderBuffer(ssbo_prev);
    rlUnloadShaderBuffer(ssbo_curr);
    rlUnloadShaderBuffer(ssbo_next);

    rUlnloadShader(comp_shader);
    rlUnloadShaderProgram(prog_comp_shader);

    UnloadTexture(white_tex);
    UnloadShader(frag_shader);

    CloseWindow();

    return 0;
}