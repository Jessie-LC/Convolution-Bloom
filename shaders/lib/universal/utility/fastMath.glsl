#define fLengthSource(x) sqrt(dotX(x))
#define fInverseLengthSource(x) inversesqrt(dotX(x))
#define fNormalizeSource(x) x * fInverseLengthSource(x)
#define dotXSource(x) dot(x, x)

float dotX(in vec2 x) {
    return dotXSource(x);
}

float dotX(in vec3 x) {
    return dotXSource(x);
}

float dotX(in vec4 x) {
    return dotXSource(x);
}

float fLength(in vec4 x) {
    return fLengthSource(x);
}

float fLength(in vec3 x) {
    return fLengthSource(x);
}

float fLength(in vec2 x) {
    return fLengthSource(x);
}

float fInverseLength(in vec4 x) {
    return fInverseLengthSource(x);
}

float fInverseLength(in vec3 x) {
    return fInverseLengthSource(x);
}

float fInverseLength(in vec2 x) {
    return fInverseLengthSource(x);
}

vec2 fNormalize(in vec2 x) {
    return fNormalizeSource(x);
}

vec3 fNormalize(in vec3 x) {
    return fNormalizeSource(x);
}

vec4 fNormalize(in vec4 x) {
    return fNormalizeSource(x);
}

float fAcos(float x) {
	// abs() is free on input for GCN
	// I'm assuming that this is true for most modern GPUs.
    // From Spectrum, taken with permission.
	float r = sqrt(1.0 - abs(x)) * (-0.175394 * abs(x) + hpi);
	return x < 0.0 ? pi - r : r;
}