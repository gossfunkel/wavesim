#version 450
// test script that changes the colour of the point

// pass value into shader from main code
uniform vec2 resolution;
//mediump vec2 gl_PointCoord; //fragment position within a point (point rasterization only) 

//uniform sampler2D p3d_Texture0;

// input 
in vec2 texcoord;
//in vec3 col;
in vec4 col;

// out to screen
out vec4 p3d_FragColor;

void main() {
	// fade out colour from centre
	vec2 uv = vec2((texcoord.x+.5)/2.,(texcoord.y+.5)/2.);
	p3d_FragColor = vec4(col.x - uv.x - uv.y,
		col.y - uv.x - uv.y,
		col.z - uv.x - uv.y,
		col.w);

}
