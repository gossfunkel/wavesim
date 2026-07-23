#version 430

//TODO pass these in as uniforms
#define WIDTH 1800
#define HEIGHT 1000

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;

// Output fragment color
out vec4 finalColor;

// ssbo for current frame
layout(std430, binding = 1) readonly buffer ssbo_curr {
    float mag_curr[];
}

void main() {
    uint idx = fragTexCoord.x + fragTexCoord.y * WIDTH;
    finalColor = vec4(mag_curr[idx]/20., -mag_curr[idx]/20., 0., 1.);
}