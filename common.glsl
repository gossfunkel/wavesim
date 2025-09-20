#pragma once

struct DataPoint {
	vec3 pos;
	vec3 normal;
	vec4 col;
	float size;
}

layout(std450) buffer DataPointBuffer {
	DataPoint dataPoints[];
}