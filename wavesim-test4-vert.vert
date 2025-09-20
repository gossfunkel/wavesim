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
const float oneOverRt4Pi = 1./(2*pi_sqrt);
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
	return phase/360 + pow(piConstants[3],min(max(l-1,0),1)) * piConstants[l] 
					* (pow(r.x,clamp(max(m,0),0,1)+clamp(-1-m,0,1)) 
					* pow(r.y,clamp(-1 * min(m,0),0,1))
					* ((3*max(clamp(max(l-1,0),0,1) - clamp(m*m,0,1),0))*pow(r.z,l-abs(m)))
					+ pow(r.x,min(max(m-1,0),1)) - pow(r.y*r.y*r.y,min(max(m-1,0),1)) 
					- (dist*dist*max(clamp(max(l-1,0),0,1) - clamp(m*m,0,1),0)) )/pow(dist,l);
}

float radial (float r, int n, int l) {
	return pow(4-n,4) * (numConstants[n-1 + max(n-2,0)] 
				* (1/pow(r,(n-1)-l) - ((n-1)-l)/(n* (n-1) * pow(r,(n-2) + l)) + (n-1)/(n*n*pow(r,n-3))) 
				* pow(r,n-1) * exp((-1. * r)/n));
}

void main() {
	piConstants[0] = oneOverRt4Pi; 
	piConstants[1] = sqrt34pi;
	piConstants[2] = halfRt15pi;
	piConstants[3] = halfRt3pi;

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
	
	int n = 3; // n is a whole number, and tells us the energy level of the function
	int l = 2; // l is a natural number < n, and tells us the geometry of the function
	int m = 0; // |m| <= l, and tells us which configuration of the function this is
	// quantum number ms is not handled here. What do you expect of me?!?

	float vertexPhase = sphericalHarmonic(r, mod(frameNum,360.), dist, l, m);
	float vertexPhaseInv = sphericalHarmonic(r, mod(frameNum+180.,360.), dist, l, m);
	float radialVal = clamp(radial(dist, n, l),-1.,1.);

	float radPosComp = max(radialVal, 0.);
	float radNegComp = -1 * min(radialVal, 0.);

	col = vec4(((4*vertexPhase - .5)-(4*vertexPhase - .5)*(4*vertexPhase - .5))+1., 
				((4*vertexPhase - 1.5)-(4*vertexPhase - 1.5)*(4*vertexPhase - 1.5))+1.,
				((4*vertexPhase - 2.5)-(4*vertexPhase - 2.5)*(4*vertexPhase - 2.5))+1.,
				radPosComp * scale); // set transparency equal to the absolute value of the radial func, product with the scale
	vec4 colInv = vec4(((4*vertexPhaseInv - .5)-(4*vertexPhaseInv - .5)*(4*vertexPhaseInv - .5))+1., 
				((4*vertexPhaseInv - 1.5)-(4*vertexPhaseInv - 1.5)*(4*vertexPhaseInv - 1.5))+1.,
				((4*vertexPhaseInv - 2.5)-(4*vertexPhaseInv - 2.5)*(4*vertexPhaseInv - 2.5))+1.,
				radNegComp * scale); 
	col.x = col.x * radPosComp + colInv.x * radNegComp;
	col.y = col.y * radPosComp + colInv.y * radNegComp;
	col.z = col.z * radPosComp + colInv.z * radNegComp;
	gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
	//gl_Position = p3d_ViewProjectionMatrix * p3d_Vertex;
	texcoord = p3d_MultiTexCoord0;
}

