#version 450

/* DRAWBUFFERS:34 */
layout(location = 0) out vec3 kernel_re;
layout(location = 1) out vec3 kernel_im;

//#define INCLUDE_PHASE //This had virtually no impact on the output, but I have it here for the potential accuracy increase.
#define BLADES 6 //[3 4 5 6 7 8 9 10]
#define Z 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0] This is the distance from the aperture to the sensor plane in CM

uniform sampler2D colortex9;
uniform sampler2D noisetex;

uniform float viewWidth, viewHeight;

in vec2 textureCoordinate;

const float scale = 3000.0;

#include "/lib/universal/universal.glsl"

vec2 IndexToDistance(int i, int j, int N) {
    float x = (float(i) - float(N / 2)) * rcp(float(N));
    float y = (float(N / 2) - float(j)) * rcp(float(N));

    return vec2(x, y);
}

float Aperture(in vec2 uv) {
    const int blades = BLADES;

    float r = 0.0;
    for(int i = 0; i < blades; ++i) {
        const float angle = tau * (i / float(blades));

        mat2 rot = Rotate(blades * angle);

		vec2 axis = rot * vec2(cos(angle), sin(angle));

        r = max(r, dot(axis, uv));
    }

    r = mix(r, dot(uv * 2.5, uv * 2.5), 0.0);

	return saturate(step(1.0, saturate(1.0 - (r - 0.2))));
}

complexFloat h(in vec3 position, in float k, in float lambda) {
    position.z /= 100.0;
    return complexExp(complexMul(complexMul(complexFloat(0.0, 1.0), pi / (lambda * position.z)), square(position.x / scale) + square(position.y / scale)));
}

void main() {
	vec3 glare_re = vec3(0.0);
	vec3 glare_im = vec3(0.0);

	vec2 position = IndexToDistance(int(gl_FragCoord.x), int(gl_FragCoord.y), SIZE);
    vec2 uv = gl_FragCoord.st / SIZE;

    float opening = Aperture(position);

    float wavelengthR = 680e-9;
    float wavelengthG = 550e-9;
    float wavelengthB = 440e-9;

    complexFloat E_r = complexMul(1.0, complexMul(opening, h(vec3(position, Z), 2.0 * pi / wavelengthR, wavelengthR)));
    complexFloat E_g = complexMul(1.0, complexMul(opening, h(vec3(position, Z), 2.0 * pi / wavelengthG, wavelengthG)));
    complexFloat E_b = complexMul(1.0, complexMul(opening, h(vec3(position, Z), 2.0 * pi / wavelengthB, wavelengthB)));

    if(isnan(E_r.r)) {
        E_r.r = 0.0;
    }
    if(isnan(E_r.i)) {
        E_r.i = 0.0;
    }
    if(isnan(E_g.r)) {
        E_g.r = 0.0;
    }
    if(isnan(E_g.i)) {
        E_g.i = 0.0;
    }
    if(isnan(E_b.r)) {
        E_b.r = 0.0;
    }
    if(isnan(E_b.i)) {
        E_b.i = 0.0;
    }
    if(isinf(E_r.r)) {
        E_r.r = 1.0;
    }
    if(isinf(E_r.i)) {
        E_r.i = 1.0;
    }
    if(isinf(E_g.r)) {
        E_g.r = 1.0;
    }
    if(isinf(E_g.i)) {
        E_g.i = 1.0;
    }
    if(isinf(E_b.r)) {
        E_b.r = 1.0;
    }
    if(isinf(E_b.i)) {
        E_b.i = 1.0;
    }

    glare_re += vec3(E_r.r, E_g.r, E_b.r);
    glare_im += vec3(E_r.i, E_g.i, E_b.i);

    kernel_re = glare_re;
    kernel_im = glare_im;
}