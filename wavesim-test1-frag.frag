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

// this function from https://www.vertexfragment.com/ramblings/polar-coordinates/
vec2 cartesianToPolar(vec2 cartesian) {
    // vector from cartesian point to origin(vec2)
    vec2 originVec = cartesian - vec2(0.0, 0.0);
    float rad = length(originVec);
    float theta = atan(originVec.y, originVec.x);
    return vec2(rad, theta);
}

void main() {
	// simply fill geom with colour
	//vec3 col = vec3(texcoord.x,texcoord.y,1.2);
	//col -= (texcoord.x*10. + texcoord.y*10.);
	//vec3 uv = (texcoord * 2. - iResolution.xy)/iResolution.y;
	//vec3 col = p3d_Color.xyz;
	//p3d_FragColor = vec4(col,1.);
	p3d_FragColor = col;
	//p3d_FragColor = vec4(1.,1.,1.,1.);
	//p3d_FragColor = p3d_Color; //- vec4(.5,0.,1.,0.);

    // Normalized polar coordinates
    //vec2 uvCart = (texcoord * 2. - iResolution.xy)/iResolution.y;
    //vec2 uv = cartesianToPolar(uvCart);

	// draw a circle for every vertex
	// code from @Monkey on stackexchange https://stackoverflow.com/questions/12945277/drawing-antialiased-circle-using-shaders
	// 		and @ZachSaucier https://gist.github.com/ZachSaucier/f924f49fe8e8d8c9e5a1ae305ff6716a
	/*float border = .01;
	float r = 1.;
	vec4 colour0 = vec4(0.,0.,0.,1.);
	vec4 colour1 = vec4(0.6,0.7,1.2,1.);

	vec2 midpoint = texcoord - vec2(r,r);
	float distance = r*r - (midpoint.x * midpoint.x + midpoint.y * midpoint.y);
	float t = 1. - distance;
	//float t = mix( distance / border, 1., max(0., sign(distance - border)) );
	/*float t = 0.;
	if (distance > border) 
		t = 1.;
	else if (distance > 0.)
		t = distance / border;*/

	//p3d_FragColor = mix(colour0, colour1, t);

	//if (texcoord.x + texcoord.y < 20.)
	//	p3d_FragColor = vec4(1.,1.,1.,1.);
	//else
	//	p3d_FragColor = vec4(0.,0.,0.,0.);

}
