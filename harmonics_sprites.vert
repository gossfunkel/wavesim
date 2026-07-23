#version 430

uniform mat4 p3d_ModelViewMatrix;
uniform mat4 p3d_ProjectionMatrix;
//uniform mat4 p3d_ModelViewProjectionMatrix;

in vec3 p3d_Vertex;

layout (std430, binding = 0) buffer sprite_buff {
    vec3 pos[];
};

out vec2 texcoord;
flat out uint sprite_idx;

void main() {
    sprite_idx = gl_VertexID / 3;
    uint corner_idx = gl_VertexID % 3;

    vec4 posn = p3d_ModelViewMatrix * vec4(pos[sprite_idx], 1.);
    if (corner_idx == 0) { // middle bottom
        posn.y -= .3 ;
        texcoord = vec2(.5, -.5);
    } else if (corner_idx == 1) { // top left
        posn.x -= .3;
        texcoord = vec2(-.9, 1.);
    } else { // top right
        posn.x += .3;
        texcoord = vec2(1.9, 1.);
    }

    gl_Position = p3d_ProjectionMatrix * posn;
}