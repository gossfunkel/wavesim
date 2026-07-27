#version 430

uniform mat4 p3d_ModelViewProjectionMatrix;

in vec3 p3d_Vertex;
in vec4 p3d_Color;
//uniform uint num_verts;
//in vec2 p3d_MultiTexCoord0;
out vec4 vertex_col;

layout (std430, binding = 0) buffer vert_buff {
    vec3 pos[];
};

void main() {
    //texcoord = vec2(p3d_Vertex.x,p3d_MultiTexCoord0.y);
    if (gl_VertexID%3 == 0) {
        vertex_col = vec4(1.,0.,0.,1.);
    } else if (gl_VertexID%3 == 1) {
        vertex_col = vec4(0.,1.,0.,1.);
    } else {
        vertex_col = vec4(0.,0.,1.,1.);
    }

    gl_Position = p3d_ModelViewProjectionMatrix * vec4(pos[gl_VertexID], 1.);
}