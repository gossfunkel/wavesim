#version 430

//TODO pass these in as uniforms
// uniform vec2 resolution or uniform uint width etc
#define WIDTH 1800
#define HEIGHT 1000
#define DAMP_FACTOR .9

#define get_data(x, y, ssbo) ((((x) < 0) || ((y) < 0) || ((x) > WIDTH) || ((y) > HEIGHT)) \
                                    ? (0.) : (ssbo)[(x) + WIDTH * (y)])

layout (local_size_x = 4, local_size_y = 4, local_size_z = 1) in;

layout(std430, binding = 1) readonly restrict buffer ssbo_prev {
    float mags_prev[];
};

layout(std430, binding = 2) writeonly restrict buffer ssbo_curr {
    float mags_curr[];
};

layout(std430, binding = 3) writeonly restrict buffer ssbo_next {
    float mags_next[];
};

void main() {
    uint x = gl_GlobalInvocationID.x;
    uint y = gl_GlobalInvocationID.y;

    // 4 * u(x, y, t)
    double UXYT_Q = 4. * get_data(x + y * WIDTH, mags_curr);
    double right_spr = get_data((x+1) + y * WIDTH, mags_curr);
    double left_spr = get_data((x-1) + y * WIDTH, mags_curr);
    double up_spr = get_data(x + (y-1) * WIDTH, mags_curr);
    double down_spr = get_data(x + (y+1) * WIDTH, mags_curr);
    get_data(x, y, mags_next) = (UXYT_D - get_data(x + y*WIDTH, mags_in) + ((dt * dt) / DX_2) * C_2 * 
                (right_spr + left_spr + up_spr + down_spr - UXYT_Q)) * DAMP_FACTOR;
}