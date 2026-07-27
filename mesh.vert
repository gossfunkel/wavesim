#version 430

const float TAU = 6.2831853;

uniform mat4 p3d_ModelViewProjectionMatrix;
uniform float osg_FrameTime;

in vec3 p3d_Vertex;
in vec4 p3d_Color;
//uniform uint num_verts;
//in vec2 p3d_MultiTexCoord0;
out vec4 vertex_col;

layout (std430, binding = 0) buffer vert_buff {
    vec3 pos[];
};

void main() {
    float offset = 0.;
    //texcoord = vec2(p3d_Vertex.x,p3d_MultiTexCoord0.y);
    if (gl_VertexID%3 == 0) {
        offset = TAU/6.;
    } else if (gl_VertexID%3 == 1) {
        offset = 3.*TAU/6.;
    } else {
        offset = 5.*TAU/6.;
    }

    vertex_col = vec4(sin(osg_FrameTime + offset),
                      sin(osg_FrameTime + offset + TAU/3.),
                      sin(osg_FrameTime + offset + 2.*TAU/3.),1.);

    gl_Position = p3d_ModelViewProjectionMatrix * vec4(pos[gl_VertexID], 1.);
}