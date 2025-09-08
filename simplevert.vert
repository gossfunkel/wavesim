#version 450

uniform mat4 p3d_ModelViewProjectionMatrix;
//uniform mat4 p3d_ViewProjectionMatrix;

// vertex inputs
in vec4 p3d_Vertex;
in vec2 p3d_MultiTexCoord0;
in vec4 p3d_Color;
uniform int osg_FrameNumber;

uniform float sys_scale;
//in vec4 anything; // column named anything; number of components matches that of the vertex array

// to fragment
out vec2 texcoord;
//out vec3 col;
out vec4 col;

float coulomb(vec3 r, float q1, float q2) {
	float q = q1 * q2;
	float rAbsolute = sqrt(r.x*r.x+r.y*r.y+r.z*r.z);
	if (rAbsolute == 0) return 1.5e+308;
	else return  q/(rAbsolute*rAbsolute);
}

void main() {
	float frameNum = float(osg_FrameNumber)/50.;
	/*vec3 charge1 = vec3(mod(sys_scale/2+(sys_scale/2*sin(frameNum)),sys_scale),
						mod(sys_scale/2+(sys_scale/2*cos(frameNum)),sys_scale),
						mod(sys_scale/2+(sys_scale/2* -sin(frameNum)),sys_scale));
	vec3 charge2 = vec3(mod(sys_scale/2+(sys_scale/2* -sin(frameNum)),sys_scale),
						mod(sys_scale/2+(sys_scale/2* -cos(frameNum)),sys_scale),
						mod(sys_scale/2+(sys_scale/2* sin(frameNum)),sys_scale));*/
	vec3 charge1 = vec3(sys_scale/2+(sys_scale/4*sin(frameNum)),
						sys_scale/2+(sys_scale/4*cos(frameNum)),
						sys_scale/2+(sys_scale/4* -sin(frameNum)));
	vec3 charge2 = vec3(sys_scale/2+(sys_scale/4* -sin(frameNum)),
						sys_scale/2+(sys_scale/4),
						sys_scale/2+(sys_scale/4* sin(frameNum)));
	float coulForce1 = coulomb(p3d_Vertex.xyz - charge1,1.,5.);
	float coulForce2 = coulomb(p3d_Vertex.xyz - charge2,1.,10.);
	//col = vec4(0., coulForce1, coulForce2, (coulForce1+coulForce2)/10.);
	col = vec4((coulForce1+coulForce2)/2., coulForce1, coulForce2, 1.);
	gl_Position = p3d_ModelViewProjectionMatrix * p3d_Vertex;
	//gl_Position = p3d_ViewProjectionMatrix * p3d_Vertex;
	texcoord = p3d_MultiTexCoord0;

	// pass vertices as texcoords
}
