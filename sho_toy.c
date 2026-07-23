#include <raylib.h>
#include <raymath.h>

#define NUM_SPRINGS 200
#define DAMP_FACTOR .999f

// square of distance between pts
#define DX_2 .5
// square of wave velocity
#define C_2 2.

#define SCREEN_WIDTH 1800
#define SCREEN_HEIGHT 1000

double spring_mags[NUM_SPRINGS] = {};
double prev_mags[NUM_SPRINGS] = {};
//float spring_vels[NUM_SPRINGS] = {};
Vector2 spring_pos[NUM_SPRINGS] = {};

/* this method accumulates a lot of errors or is highly unstable (or both), im not sure lol
static void calc_sho(int spring, float left_spr, float right_spr) {
    // a ~= f = -kx
    // rate of change of velocity is given by previous velocity + difference between mag and neighbour mags
    spring_vels[spring] += GetFrameTime() * (((left_spr + right_spr) / 2.f) - spring_mags[spring]) * DAMP_FACTOR;
    // rate of change of magnitude is velocity
    spring_mags[spring] += spring_vels[spring];
}*/

// spring_mags[spring] is u(x,t), left_spr is u(x-dx,t), right_spr is u(x+dx,t)
static void calc_sho_pde(int spring, double left_spr, double right_spr, double dt) {
    double prev_mag = spring_mags[spring];
    double UXT_D = 2. * prev_mag;
    spring_mags[spring] = (UXT_D - prev_mags[spring] + ((dt * dt) / DX_2) * C_2 * 
                (right_spr - UXT_D + left_spr)) * DAMP_FACTOR;
    prev_mags[spring] = prev_mag;
}

int main() {
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Simple Harmonic Oscillators");

    // initialise spring positions and magnitudes
    for (int spr_id = 0; spr_id < NUM_SPRINGS; ++spr_id) {
        spring_pos[spr_id] = (Vector2){ spr_id * (SCREEN_WIDTH/NUM_SPRINGS) 
                                               + (SCREEN_WIDTH/(NUM_SPRINGS*2.)), SCREEN_HEIGHT/2. };
                                //2D:   spr_id * (SCREEN_HEIGHT/NUM_SPRINGS) + (SCREEN_HEIGHT/(NUM_SPRINGS*2))}; 
        spring_mags[spr_id] = 0.;
        prev_mags[spr_id] = 0.;
        //spring_vels[spr_id] = 0.f;
    }

    // initialise a unit impulse at the speed of wave propagation
    spring_mags[NUM_SPRINGS/2 - 1] =  sqrt(C_2);
    spring_mags[NUM_SPRINGS/2]     =       C_2;
    prev_mags[NUM_SPRINGS/2]       =  sqrt(C_2);
    prev_mags[NUM_SPRINGS/2 + 1]   = -sqrt(C_2);
    spring_mags[NUM_SPRINGS/2 + 1] =      -C_2;
    spring_mags[NUM_SPRINGS/2 + 2] = -sqrt(C_2);

    SetTargetFPS(60);

    while(!WindowShouldClose()) {                                   // GAME loop --- 

        double dt = GetFrameTime();

        // update velocities and positions (ends pinned)
        calc_sho_pde(0, -spring_mags[1], spring_mags[1], dt);
        for (int spr_id = 1; spr_id < NUM_SPRINGS-1; ++spr_id)
            calc_sho_pde(spr_id, spring_mags[spr_id-1], spring_mags[spr_id+1], dt);
        calc_sho_pde(NUM_SPRINGS-1, spring_mags[NUM_SPRINGS-1], -spring_mags[NUM_SPRINGS-1], dt);

        BeginDrawing();                                                 // DRAW stage ---

            ClearBackground(BLACK);

            // draw circles to represent magnitudes from two perspectives (orthogonal and perpendicular)
            for (int spr_id = 0; spr_id < NUM_SPRINGS; ++spr_id) {
                DrawCircleV(spring_pos[spr_id], 1 - spring_mags[spr_id]/2, RED);
                DrawCircleV(spring_pos[spr_id], 1 + spring_mags[spr_id]/2, GREEN);
                DrawCircle(spring_pos[spr_id].x, SCREEN_HEIGHT/2 - spring_mags[spr_id] * 10, 2, BLUE);
            }

        EndDrawing();

    }
    CloseWindow();

    return 0;
}