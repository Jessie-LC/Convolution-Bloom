#version 450

#define Z 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0] This is the distance from the aperture to the sensor plane in CM

/* DRAWBUFFERS:34 */
layout(location = 0) out vec3 kernel_re;
layout(location = 1) out vec3 kernel_im;

uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex9;

uniform sampler2D noisetex;

uniform float viewWidth, viewHeight;

in vec2 textureCoordinate;

#include "/lib/universal/universal.glsl"

const float scale = 3000.0;

vec2 IndexToDistance(int i, int j, int N) {
    float x = (float(i) - float(N / 2)) * rcp(float(N));
    float y = (float(N / 2) - float(j)) * rcp(float(N));

    return vec2(x, y);
}
vec2 IndexToDistance(float i, float j, float N) {
    float x = (float(i) - float(N / 2)) * rcp(float(N));
    float y = (float(N / 2) - float(j)) * rcp(float(N));

    return vec2(x, y);
}

// Spectrum to xyz approx function from "Simple Analytic Approximations to the CIE XYZ Color Matching Functions"
// http://jcgt.org/published/0002/02/01/paper.pdf
//Inputs:  Wavelength in nanometers
float xFit_1931(float wave)
{
    float t1 = (wave - 442.0f)*((wave < 442.0f) ? 0.0624f : 0.0374f);
    float t2 = (wave - 599.8f)*((wave < 599.8f) ? 0.0264f : 0.0323f);
    float t3 = (wave - 501.1f)*((wave < 501.1f) ? 0.0490f : 0.0382f);
    return 0.362f*exp(-0.5f*t1*t1) + 1.056f*exp(-0.5f*t2*t2) - 0.065f*exp(-0.5f*t3*t3);
}
float yFit_1931(float wave)
{
    float t1 = (wave - 568.8f)*((wave < 568.8f) ? 0.0213f : 0.0247f);
    float t2 = (wave - 530.9f)*((wave < 530.9f) ? 0.0613f : 0.0322f);
    return 0.821f*exp(-0.5f*t1*t1) + 0.286f*exp(-0.5f*t2*t2);
}
float zFit_1931(float wave)
{
    float t1 = (wave - 437.0f)*((wave < 437.0f) ? 0.0845f : 0.0278f);
    float t2 = (wave - 459.0f)*((wave < 459.0f) ? 0.0385f : 0.0725f);

    return 1.217f*exp(-0.5f*t1*t1) + 0.681f*exp(-0.5f*t2*t2);
}

// RGB-XYZ Matrix Calculator
// http://www.russellcottrell.com/photo/matrixCalculator.htm
// Based on equations found here:
// http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
// And Rec. 2020 values found here:
// https://en.wikipedia.org/wiki/Rec._2020
// https://en.wikipedia.org/wiki/Rec._709
// https://en.wikipedia.org/wiki/SRGB
vec3 XYZtosRGB(vec3 XYZ)
{
    vec3 rgb;
    rgb.x = XYZ.x *  3.2409699f + XYZ.y * -1.5373832f + XYZ.z * -0.4986108f;
    rgb.y = XYZ.x * -0.9692436f + XYZ.y *  1.8759675f + XYZ.z *  0.0415551f;
    rgb.z = XYZ.x *  0.0556301f + XYZ.y * -0.2039770f + XYZ.z *  1.0569715f;
    
    return rgb;
}

float sinc(float v)
{
    float res = 1.0;
    if (abs(v) > 0.0001)
        res = sin(v) / v;

    return res;
}

// http://www.jcgt.org/published/0009/03/02/
uvec3 pcg3d(uvec3 v) {
    v = v*1664525u + 1013904223u;
    v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
    v ^= v >> 16u;
    v.x += v.y*v.z; v.y += v.z*v.x; v.z += v.x*v.y;
    return v;
}
uvec4 pcg4d(uvec4 v) {
    v = v*1664525u + 1013904223u;
    v.x += v.y*v.w; v.y += v.z*v.x; v.z += v.x*v.y; v.w += v.y*v.z;
    v ^= v >> 16u;
    v.x += v.y*v.w; v.y += v.z*v.x; v.z += v.x*v.y; v.w += v.y*v.z;
    return v;
}

// https://nullprogram.com/blog/2018/07/31/
uint lowbias32(uint x) {
    x ^= x >> 16;
    x *= 0x7feb352du;
    x ^= x >> 15;
    x *= 0x846ca68bu;
    x ^= x >> 16;
    return x;
}

uint randState;
void InitRand(uint seed) { randState = lowbias32(seed); }
uint RandNext() { return randState = lowbias32(randState); }
#define RandNext2() uvec2(RandNext(), RandNext())
#define RandNext3() uvec3(RandNext2(), RandNext())
#define RandNext4() uvec4(RandNext3(), RandNext())
#define RandNextF() (float(RandNext()) / float(0xffffffffu))
#define RandNext2F() (vec2(RandNext2()) / float(0xffffffffu))
#define RandNext3F() (vec3(RandNext3()) / float(0xffffffffu))
#define RandNext4F() (vec4(RandNext4()) / float(0xffffffffu))

float Aperture(in vec2 uv) {
    const int blades = 126;

    float r = 0.0;
    for(int i = 0; i < blades; ++i) {
        float angle = 2.0 * pi * (float(i) / float(blades));

        mat2 rot = Rotate(float(blades) * angle + radians(180.0));

		vec2 axis = rot * vec2(cos(angle), sin(angle));

        r = max(r, dot(axis, uv));
    }

	return float(r < 0.003);//clamp(step(1.0, clamp(1.0 - (r - 0.1), 0.0, 1.0)), 0.0, 1.0);
}

float EyeLash(in vec2 uv) {
    uv.x = uv.x*1.777 - 0.38; //squarify UVs
    
    //if(uv.y <0.5)  uv.y = 1.0-uv.y; //mirror UVs vertically
    
    vec2 uv1 = uv.xy;
    
    //vertical offset
    if (uv1.y < 0.5) uv1.y = 1.0 - uv1.y;
    //float y_offset = sin(iTime)*0.05 - 0.1;
    //uv1.y += y_offset;

    float distance_to_upperlashes_center = distance(vec2(uv1.x, uv1.y * 2.0 + sin(1.0*2.0)*0.5), vec2(0.5, 1.9));

    //if (distance_to_upperlashes_center < 0.4)
    {
        vec2 uv2 = uv1.xy;
        
        //curve lashes
        //uv2.x = (uv2.x-0.5) * (1.0 - uv2.y*3.0) +0.5;        

        float angle_around_center = (/*(iTime*0.5) +*/ 1.0 + acos(dot(normalize(uv2.xy - vec2(0.5, 0.5 + 0.5)), vec2(1, 0))));

        //draw lashes
        if (abs(fract((angle_around_center - 0.03 ) * 8.0 )) < 0.4 - distance_to_upperlashes_center )
        {
            return 0.0;
            //col = vec3(abs(fract((angle_around_center - 0.03 ) * 16.0))*2.0);
        }
    }

    return 1.0;
}

void main() {
    vec2 coordinate = textureCoordinate;

    vec3 kernel_image = texture(colortex9, coordinate).rgb * 100.0;//complexAbs(complexVec3(texture(colortex3, coordinate).rgb, texture(colortex4, coordinate).rgb));

    int spectralSamples = 16;

    const float blur = 1.0;
    const float lambdaStart = 380.0;
    const float lambdaEnd   = 780.0;

    float x = gl_FragCoord.x - 0.5;
    float y = gl_FragCoord.y - 0.5;

    float dw = (lambdaEnd - lambdaStart) / spectralSamples;

    //*
    vec3 XYZIrradiance = vec3(0.0);
    for (int i = 0; i < spectralSamples; ++i) {
        float wavelength = lambdaStart + (float(i) + 0.5f)*dw;//(dw * (float(wi) / (spectralSamples - 1))) + lambdaStart;

        vec2 rng = RandNext2F();

		float dx = (x + blur * (RandNextF())) / 1024.0;
		float dy = (y + blur * (RandNextF())) / 1024.0;
		dx -= 0.5; dy -= 0.5;
        vec2 dxy = vec2(dx, dy);//IndexToDistance(x + blur * (rng.x), y + blur * (rng.y), 1024.0);

        vec2 sxy = dxy * (vec2(wavelength / 575.0, wavelength / 575.0) * 0.5);

        float r = RandNextF() > 0.5f ? 1.0f : -1.0f;
        float angle = r;

        vec2 rxy = sxy;
        sxy.x = rxy.x * cos(angle) + rxy.y * sin(angle);
        sxy.y = rxy.y * cos(angle) - rxy.x * sin(angle);

        XYZIrradiance.x += Aperture(sxy) * (texture(noisetex, (sxy + 0.5)).r * 0.8 + 0.2) * xFit_1931(wavelength) * dw;
        XYZIrradiance.y += Aperture(sxy) * (texture(noisetex, (sxy + 0.5)).r * 0.8 + 0.2) * yFit_1931(wavelength) * dw;
        XYZIrradiance.z += Aperture(sxy) * (texture(noisetex, (sxy + 0.5)).r * 0.8 + 0.2) * zFit_1931(wavelength) * dw;
    }

    kernel_re = clamp(XYZtosRGB(XYZIrradiance) * 1.0, 3.4e-38, 3.4e38);
    kernel_im = vec3(0.0);
}