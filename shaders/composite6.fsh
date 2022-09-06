#version 450

#define Z 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0] This is the distance from the aperture to the sensor plane in CM

/* DRAWBUFFERS:34 */
layout(location = 0) out vec3 kernel_re;
layout(location = 1) out vec3 kernel_im;

uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex9;

uniform float viewWidth, viewHeight;

in vec2 textureCoordinate;

#include "/lib/universal/universal.glsl"

const float scale = 3000.0;

vec2 IndexToDistance(int i, int j, int N) {
    float x = (float(i) - float(N / 2)) * rcp(float(N));
    float y = (float(N / 2) - float(j)) * rcp(float(N));

    return vec2(x, y);
}

void main() {
	vec3 glare_re = texture(colortex3, textureCoordinate).rgb;
	vec3 glare_im = texture(colortex4, textureCoordinate).rgb;

	complexVec3 glare = complexMul(vec3(0.02), vectorsToComplex(glare_re, glare_im));

	vec3 mul = square(complexAbs(glare));

    kernel_re = clamp(texture(colortex9, textureCoordinate).rgb * 1e-3, 1e-5, 3.4e38);
    kernel_im = vec3(0.0);
}