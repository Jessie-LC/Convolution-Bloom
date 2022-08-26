#version 450

/* DRAWBUFFERS:34 */
layout(location = 0) out vec3 kernel_re;
layout(location = 1) out vec3 kernel_im;

uniform sampler2D colortex3;
uniform sampler2D colortex4;

uniform float viewWidth, viewHeight;

in vec2 textureCoordinate;

#include "/lib/universal/universal.glsl"

void main() {
	vec3 glare_re = texture(colortex3, textureCoordinate).rgb;
	vec3 glare_im = texture(colortex4, textureCoordinate).rgb;

	vec3 mul = square(complexAbs(vectorsToComplex(glare_re, glare_im)));

    kernel_re = mul;
    kernel_im = vec3(0.0);
}