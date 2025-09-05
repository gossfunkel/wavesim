#version 450

uniform mat4 p3d_ModelViewProjectionMatrix;

// vertex inputs
in vec4 p3d_Vertex;
in vec2 p3d_MultiTexCoord0;
in vec4 p3d_Color;
//in vec4 anything; // column named anything; number of components matches that of the vertex array

// to fragment
out vec2 texcoord;
//out vec3 col;
out vec4 col;

void main() {
	gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
	texcoord = p3d_MultiTexCoord0;
	col = p3d_Color;

	// pass vertices as texcoords
}
