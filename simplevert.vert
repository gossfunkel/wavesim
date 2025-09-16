#version 450

// variable vertex shader inputs (unique per vertex)
uniform mat4 p3d_ModelViewProjectionMatrix;
//uniform mat4 p3d_ViewProjectionMatrix;
in vec4 p3d_Vertex;
in vec2 p3d_MultiTexCoord0;
in vec4 p3d_Color;
in float scale;

// uniform vertex shader inputs (shared across vertices)
uniform int osg_FrameNumber;
uniform float sys_scale;

// mathematical constants (precompiled; used in functions)
const float pi = 3.141592653589793238462643383;
const float pi_sqrt = sqrt(pi);
const float sqrt34pi = sqrt(3./(4.*pi));
const float halfRt15pi = sqrt(15./pi)/2.;
const float quartRt5pi = sqrt(5./pi)/4.;

const float oneOverRt2 = 1./sqrt(2.);

// output variables sent to fragment shader
out vec2 texcoord;
out vec4 col;

/*float coulomb(vec3 r, float q1, float q2) {
	float q = q1 * q2;
	float rAbsolute = sqrt(r.x*r.x+r.y*r.y+r.z*r.z);
	if (rAbsolute == 0) return 1.5e+308;
	else return  q/(rAbsolute*rAbsolute);
}*/

float spherical_Y00 (float phase) { // S-type
	return phase/360. + 1./(2. * pi_sqrt);
}

float spherical_Y1 (float phase, float axis, float dist) {
	// simply pass p3d_Vertex.x/y/z to the axis variable for the appropriately-oriented p-orbital
	// 	n.b. remember that the z-axis in this coordinate space corresponds to the y-axis in the mathematical cartesian 
	return phase/360. + sqrt34pi * (axis/dist);
}

float spherical_Y2m2 (vec3 r, float phase, float dist) { // Dxy
	return phase/360. + halfRt15pi * ((r.x*r.y)/(dist*dist));
}

float spherical_Y2m1 (vec3 r, float phase, float dist) { // Dyz
	return phase/360. + halfRt15pi * ((r.y*r.z)/(dist*dist));
}

float spherical_Y20 (vec3 r, float phase, float dist) { // D3z^2
	return phase/360. + quartRt5pi * ((3*r.z*r.z - dist*dist)/(dist*dist));
}

float spherical_Y21 (vec3 r, float phase, float dist) { // Dxz
	return phase/360. + halfRt15pi * ((r.x*r.z)/(dist*dist));
}

float spherical_Y22 (vec3 r, float phase, float dist) { // Dx^2-y^2
	return phase/360. + .5 * halfRt15pi * ((r.x*r.x - r.y*r.y)/(dist*dist));
}

float radial_R10 (float r) {
	// e^0 = 1, e^-10 = 0.0000454, e^-1 = 0.368, e^1 = 2.718, e^10 = 22,026.5
	// so we normalise r to negative values 0 to -10
	return 2. * exp(-abs(r));
}

float radial_R20 (float r) {
	// max output at 0: 1/sqrt(2) = 0.707, at 1: 0.607, at 10: -0.0191
	// n.b. phase inversion
	r = -abs(r/2.);
	return oneOverRt2 * (1+r)*exp(r);
}

void main() {
	float frameNum = float(osg_FrameNumber)/4.;
	vec3 midpoint = vec3(sys_scale/2,sys_scale/2,sys_scale/2);
	float r = sqrt(abs((midpoint.x-p3d_Vertex.x)*(midpoint.x-p3d_Vertex.x)) + 
					abs((midpoint.y-p3d_Vertex.y)*(midpoint.y-p3d_Vertex.y)) +
					abs((midpoint.z-p3d_Vertex.z)*(midpoint.z-p3d_Vertex.z)));

	// this line is not needed for the first eigenstate; only P and above require the distance to centre
	// n.b. this is only required due to the coordinate system; if the origin was at the centre, we would not need this
	vec3 distVert = vec3(p3d_Vertex.x-sys_scale/2,p3d_Vertex.y-sys_scale/2,p3d_Vertex.z-sys_scale/2);
	
	// S-orbital style
	float vertexPhase = mod(spherical_Y00(frameNum),1.);
	float radialVal = min(radial_R10(r),.65);

	// P-orbital style
	//float vertexPhase = mod(spherical_Y1(frameNum, distVert.y, r),1.);
	//float radialVal = min(radial_R20(r),.65);

	// D-orbital style
	//float vertexPhase = mod(spherical_Y22(distVert, frameNum, r),1.);

	col = vec4(((4*vertexPhase - .5)-(4*vertexPhase - .5)*(4*vertexPhase - .5))+1., 
				((4*vertexPhase - 1.5)-(4*vertexPhase - 1.5)*(4*vertexPhase - 1.5))+1.,
				((4*vertexPhase - 2.5)-(4*vertexPhase - 2.5)*(4*vertexPhase - 2.5))+1.,
				radialVal);
	gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
	//gl_Position = p3d_ViewProjectionMatrix * p3d_Vertex;
	texcoord = p3d_MultiTexCoord0;
}

