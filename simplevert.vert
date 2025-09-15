#version 450

uniform mat4 p3d_ModelViewProjectionMatrix;
//uniform mat4 p3d_ViewProjectionMatrix;

// vertex inputs
in vec4 p3d_Vertex;
in vec2 p3d_MultiTexCoord0;
in vec4 p3d_Color;
in float scale;
uniform int osg_FrameNumber;

const float pi_sqrt = sqrt(3.141592653589793238462643383);
const float sqrt34pi = sqrt(3/(4*3.141592653589793238462643383));

uniform float sys_scale;
//in vec4 anything; // column named anything; number of components matches that of the vertex array

// to fragment
out vec2 texcoord;
//out vec3 col;
out vec4 col;

/*float coulomb(vec3 r, float q1, float q2) {
	float q = q1 * q2;
	float rAbsolute = sqrt(r.x*r.x+r.y*r.y+r.z*r.z);
	if (rAbsolute == 0) return 1.5e+308;
	else return  q/(rAbsolute*rAbsolute);
}*/

float spherical_Y00 (vec3 r, float phase) {
	return (phase/(2*pi_sqrt));
}

float spherical_Y1m1 (vec3 r, float phase, float y, float dist) {
	return phase/360+(sqrt34pi*(y/dist));
}

void main() {
	float frameNum = float(osg_FrameNumber)/4.;
	vec3 midpoint = vec3(sys_scale/2,sys_scale/2,sys_scale/2);
	float r = sqrt(abs((midpoint.x-p3d_Vertex.x)*(midpoint.x-p3d_Vertex.x)) + 
					abs((midpoint.y-p3d_Vertex.y)*(midpoint.y-p3d_Vertex.y)) +
					abs((midpoint.z-p3d_Vertex.z)*(midpoint.z-p3d_Vertex.z)));
	float sphericalHarmonic = spherical_Y1m1(p3d_Vertex.yzx, (int(frameNum)%360),p3d_Vertex.z-sys_scale/2,r);	// value for current phase
	float sphericalHarmonicMax = spherical_Y1m1(p3d_Vertex.xyz, 360,sys_scale/2,14.1421356237);				// value for max phase, y, dist (pythagoras)
	float propSpherHarm = sphericalHarmonic/sphericalHarmonicMax;					// normalise output to range of 0 to 1
	col = vec4(((4*propSpherHarm - .5)-(4*propSpherHarm - .5)*(4*propSpherHarm - .5))+1., 
				((4*propSpherHarm - 1.5)-(4*propSpherHarm - 1.5)*(4*propSpherHarm - 1.5))+1.,
				((4*propSpherHarm - 2.5)-(4*propSpherHarm - 2.5)*(4*propSpherHarm - 2.5))+1.,
				scale);
	gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
	//gl_Position = p3d_ViewProjectionMatrix * p3d_Vertex;
	texcoord = p3d_MultiTexCoord0;

	// pass vertices as texcoords
}

