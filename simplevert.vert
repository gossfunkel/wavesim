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
const float halfRt3pi = sqrt(3./pi)/2.;
float piConstants[6]; // index constants based on pi to array (must be populated at runtime)

//const float oneOverRt2 = 1./sqrt(2.);
const float oneOverRt24 = 1./sqrt(24.);
const float twoOverRt27 = 2./sqrt(27.);
const float eightOver27rt6 = 8. / (27 * sqrt(6.));
const float fourOver81rt30 = 4. / (81 * sqrt(30.));
float numConstants[6]; // index numerical constants to array (must be populated at runtime)

// output variables sent to fragment shader
out vec2 texcoord;
out vec4 col;

/*float coulomb(vec3 r, float q1, float q2) {
	float q = q1 * q2;
	float rAbsolute = sqrt(r.x*r.x+r.y*r.y+r.z*r.z);
	if (rAbsolute == 0) return 1.5e+308;
	else return  q/(rAbsolute*rAbsolute);
}*/

float sphericalHarmonic (vec3 r, float phase, float dist, int l, int m) { 
	return phase/360 + pow(piConstants[5],min(max(l-2.,0.),1.)) * piConstants[l] 
					* (pow(r.x,m + max(-1*max(m,-1),0.)) 
					* pow(r.y,pow(1,-1. * min(m,0.)))
					* pow(r.z,l-abs(m))
					- pow(r.y*r.y*r.y,min(max(m-1.,0),1.)) - (dist*dist*max(l - max(l - l*m,0.),0.)))/pow(dist,l);
}

float spherical_Y00 (float phase) { // S-type
	return phase/360. + 1./(2. * piConstants[1]);
}

float spherical_Y1 (float phase, float axis, float dist) {
	// simply pass p3d_Vertex.x/y/z to the axis variable for the appropriately-oriented p-orbital
	// 	n.b. remember that the z-axis in this coordinate space corresponds to the y-axis in the mathematical cartesian 
	return phase/360. + piConstants[2] * (axis/dist);
}

float spherical_Y2m2 (vec3 r, float phase, float dist) { // Dxy
	return phase/360. + piConstants[3] * ((r.x*r.y)/(dist*dist));
}

float spherical_Y2m1 (vec3 r, float phase, float dist) { // Dyz
	return phase/360. + piConstants[3] * ((r.y*r.z)/(dist*dist));
}

float spherical_Y20 (vec3 r, float phase, float dist) { // D3z^2
	return phase/360. + piConstants[4] * ((3*r.z*r.z - dist*dist)/(dist*dist));
}

float spherical_Y21 (vec3 r, float phase, float dist) { // Dxz
	return phase/360. + piConstants[3] * ((r.x*r.z)/(dist*dist));
}

float spherical_Y22 (vec3 r, float phase, float dist) { // Dx^2-y^2
	return phase/360. + .5 * piConstants[3] * ((r.x*r.x - r.y*r.y)/(dist*dist));
}

float radial (float r, int n, int l) {
	return numConstants[n-1 + max(n-2,0)] 
					* (1/pow(r,(n-1)-l) - ((n-1)-l)/(n* (n-1) * pow(r,(n-2) + l)) + (n-1)/(n*n*pow(r,n-3))) 
					* pow(r,n-1) * exp((-1. * r)/n);
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
	return numConstants[1] * (1+r)*exp(r);
}

float radial_R21 (float r) {
	return numConstants[2] * r * exp(r * -.5);
}

float radial_R30 (float r) {
	return numConstants[3] * (1. - (2. * r)/3 + (2.*r*r)/27) * exp((r * -1.)/3);
}

float radial_R31 (float r) {
	return numConstants[4] * (1. - r/6.) * r * exp((r * -1.)/3);
}

float radial_R32 (float r) {
	return numConstants[5] * r * r * exp((r * -1.)/3);
}

void main() {
	piConstants[0] = pi;
	piConstants[1] = pi_sqrt;
	piConstants[2] = sqrt34pi;
	piConstants[3] = halfRt15pi;
	piConstants[4] = quartRt5pi;
	piConstants[5] = halfRt3pi;

	numConstants[0] = 2.;
	numConstants[1] = 0.25;
	numConstants[2] = oneOverRt24;
	numConstants[3] = twoOverRt27;
	numConstants[4] = eightOver27rt6;
	numConstants[5] = fourOver81rt30;

	float frameNum = float(osg_FrameNumber)/4.;
	//float frameNum = 0.;

	// n.b. this is only required due to the coordinate system; if the origin was at the centre, we would not need this
	vec3 r = vec3(p3d_Vertex.x-sys_scale/2,p3d_Vertex.y-sys_scale/2,p3d_Vertex.z-sys_scale/2);
	vec3 midpoint = vec3(sys_scale/2,sys_scale/2,sys_scale/2);
	float dist = sqrt(abs((midpoint.x-p3d_Vertex.x)*(midpoint.x-p3d_Vertex.x)) + 
					abs((midpoint.y-p3d_Vertex.y)*(midpoint.y-p3d_Vertex.y)) +
					abs((midpoint.z-p3d_Vertex.z)*(midpoint.z-p3d_Vertex.z)));
	
	int n = 1; // n is a whole number
	int l = 0; // l is a natural number < n
	int m = 0; // |m| <= l
	float vertexPhase = mod(sphericalHarmonic(r, frameNum, dist, l, m),1.);
	//float vertexPhase = mod(spherical_Y00(frameNum),1.);
	float radialVal = min(20.*radial(dist, n, l),1.);

	// S-orbital style; l = 0, m = 0
	// 1S
	//float radialVal = min(radial_R10(r),.65);
	// 2S
	//float radialVal = min(radial_R20(r),.65);
	// 3S
	//float radialVal = min(radial_R30(r),.65);

	// P-orbital style; l = 1, m = -1 ,0, or 1
	//float vertexPhase = mod(spherical_Y1(frameNum, distVert.z, r),1.);
	// 2P
	//float radialVal = min(10.*radial_R21(r),1.); // 2P normalised to 1
	// 3P
	//float radialVal = min(10*radial_R31(r),1.);

	// D-orbital style
	//float vertexPhase = mod(spherical_Y21(distVert, frameNum, r),1.);
	// 3D
	//float radialVal = min(20.*radial_R32(r),1.);

	float radPosComp = max(radialVal, 0.);
	float radNegComp = abs(min(radialVal, 0.));

	col = vec4(((4*vertexPhase - .5)-(4*vertexPhase - .5)*(4*vertexPhase - .5))+1., 
				((4*vertexPhase - 1.5)-(4*vertexPhase - 1.5)*(4*vertexPhase - 1.5))+1.,
				((4*vertexPhase - 2.5)-(4*vertexPhase - 2.5)*(4*vertexPhase - 2.5))+1.,
				abs(radialVal) * scale); // set transparency equal to the absolute value of the radial func, product with the scale
	col.x = col.x * radPosComp + col.y * radNegComp;
	col.y = col.y * radPosComp + col.z * radNegComp;
	col.z = col.z * radPosComp + col.x * radNegComp;
	gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
	//gl_Position = p3d_ViewProjectionMatrix * p3d_Vertex;
	texcoord = p3d_MultiTexCoord0;
}

