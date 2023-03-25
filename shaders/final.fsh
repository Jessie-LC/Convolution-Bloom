#version 450

/* DRAWBUFFERS:0 */
layout(location = 0) out vec3 color;

/*
    const int colortex0Format = RGBA16F;
    const int colortex1Format = RGBA32F;
    const int colortex2Format = RGBA32F;
    const int colortex3Format = RGBA32F;
    const int colortex4Format = RGBA32F;

    const int colortex7Format = RGBA16F;
    const int colortex9Format = RGBA32F;
*/

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex9;

uniform float viewWidth, viewHeight;

in vec2 textureCoordinate;

#include "/lib/universal/universal.glsl"

void main() {
    color = clamp(abs(texture(colortex1, textureCoordinate).xyz) * 0.0001, 1e-5, 3.4e38);
    color = color / (1.0 + color);
    color = LinearToSrgb(color);

	if(gl_FragCoord.x < 512 && gl_FragCoord.y < 512) {
		vec2 coordinate = ((gl_FragCoord.xy * 2.0)) / SIZE;
		color = (texture(colortex3, 1.0 - coordinate).xyz / (1024.0 * 1024.0)) * 10.0;
	}

    //color = (texture(colortex3, textureCoordinate).rgb / (1024.0 * 1024.0)) * 1000.0;
}