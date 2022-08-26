#version 450

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;
const ivec3 workGroups = ivec3(32, 32, 1);

layout (rgba32f) uniform image2D colorimg1;
layout (rgba32f) uniform image2D colorimg2;
layout (rgba32f) uniform image2D colorimg3;
layout (rgba32f) uniform image2D colorimg4;

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;

uniform float viewWidth, viewHeight;

#include "/lib/universal/universal.glsl"

void main() {
    uvec2 invocationID = gl_GlobalInvocationID.xy;

	vec3 glare_re = imageLoad(colorimg3, ivec2(invocationID)).rgb;
	vec3 glare_im = imageLoad(colorimg4, ivec2(invocationID)).rgb;

	vec3 mul = glare_re;//square(complexAbs(vectorsToComplex(glare_re, glare_im)));
	if(any(isnan(mul))) {
		mul = vec3(0.0);
	}
	if(any(isinf(mul))) {
		mul = vec3(1.0);
	}

    vec3 amplitude_re = mul * imageLoad(colorimg1, ivec2(invocationID)).rgb;
    vec3 amplitude_im = mul * imageLoad(colorimg2, ivec2(invocationID)).rgb;

    imageStore(colorimg1, ivec2(invocationID), vec4(amplitude_re, 0.0));
    imageStore(colorimg2, ivec2(invocationID), vec4(amplitude_im, 0.0));
}