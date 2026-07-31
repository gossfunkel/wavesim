#version 430

const float TAU = 6.2831853;

uniform mat4 p3d_ModelViewProjectionMatrix;
uniform float osg_FrameTime;

in vec3 p3d_Vertex;
in vec4 p3d_Color;
//uniform uint num_verts;
//in vec2 p3d_MultiTexCoord0;
out vec4 vertex_col;
uniform uint num_verts;
uniform uint num_stacks;
uniform uint num_sectors;

layout (std430, binding = 0) buffer vert_buff {
    vec3 pos[];
};

void main() {
    float offset = 0.;
    float stack, sector = 0.;
    if (gl_VertexID != 0) {
        stack = float(((gl_VertexID-1)/num_sectors)+1);
        sector = float(((gl_VertexID-1)%num_sectors));
    }
    //texcoord = vec2(p3d_Vertex.x,p3d_MultiTexCoord0.y);
    /*
    if (gl_VertexID%4 == 0) {
        offset = TAU/4.;
    } else if (gl_VertexID%4 == 1) {
        offset = TAU/2.;
    } else if (gl_VertexID%4 == 2) {
        offset = 3.*TAU/4.;
    }*/

    //offset = TAU * (pos[gl_VertexID].x / 64.) + pos[gl_VertexID].y;

    //vertex_col = vec4(abs(sin(osg_FrameTime + offset)/3.),
    //                  abs(sin(osg_FrameTime + offset + TAU/3.)/3.),
    //                  abs(sin(osg_FrameTime + offset + 2.*TAU/3.)/3.),1.);
    float blueval = 0.;
    if (uint(osg_FrameTime)%num_verts == (gl_VertexID-1)%num_verts) {
        blueval = mod(osg_FrameTime,.1) *.5;
    } else if (uint(osg_FrameTime)%num_verts == gl_VertexID) {
        blueval = .5 + mod(osg_FrameTime,1.) * .5;
    } else if (uint(osg_FrameTime)%num_verts == (gl_VertexID+1)%num_verts) {
        blueval = 1. - mod(osg_FrameTime,1.) * .5;
    } else if (uint(osg_FrameTime)%num_verts == (gl_VertexID+2)%num_verts) {
        blueval = .5 - mod(osg_FrameTime,1.) * .5;
    }
    vertex_col = vec4(stack/float(num_stacks),sector/float(num_sectors), blueval,1.);

    gl_Position = p3d_ModelViewProjectionMatrix * vec4(pos[gl_VertexID], 1.);
}