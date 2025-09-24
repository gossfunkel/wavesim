#pragma once

struct DataPoint {
	vec4 pos;		// packed with w=1 for std430 formatting reasons(blocks of 16 floats; that's 48 bytes; or 384 bits)
	vec3 normal;
	float size;
	vec4 col;
};

layout(std430) buffer DataPointBuffer {
	DataPoint dataPoints[];
};