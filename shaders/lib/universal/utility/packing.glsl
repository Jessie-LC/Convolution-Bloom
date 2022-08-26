float packUnorm2x4(vec2 xy) {
	return dot(floor(15.0 * xy + 0.5), vec2(1.0 / 255.0, 16.0 / 255.0));
}

vec2 unpackUnorm2x4(float pack) {
	vec2 xy; xy.x = modf(pack * 255.0 / 16.0, xy.y);
	return xy * vec2(16.0 / 15.0, 1.0 / 15.0);
}

uint packUnorm2x8(vec2 x) {
	uvec2 ux = uvec2(255.0 * x + 0.5);
	return ux.x | (ux.y << 8);
}

vec2 unpackUnorm2x8(uint x) {
	uvec2 ux = uvec2(x & 0xffu, (x >> 8u) & 0xffu);
	return vec2(ux) / 255.0;
}

uint packSnorm2x8(vec2 xy) {
	uvec2 ux = uvec2(127.0 * xy + 128.5);
	return ux.x | ux.y << 8;
}

vec2 unpackSnorm2x8(uint x) {
	uvec2 xy = uvec2(x, x >> 8u) & 0xffu;
	return vec2(xy) / 127.0 - (128.0 / 127.0);
}

uint packSnorm2x12(vec2 x) {
	uvec2 ux = uvec2(2047.0 * x + 2048.5);
	return ux.x | ux.y << 12;
}

vec2 unpackSnorm2x12(uint x) {
	vec2 ux = vec2(x & 0xfffu, (x >> 12u) & 0xfffu);
	return ux / 2047.0 - (2048.0 / 2047.0);
}

vec4 EncodeRGBE8(vec3 rgb) {
    float exponentPart = floor(log2(max(max(rgb.r, rgb.g), max(rgb.b, exp2(-127.0))))); // can remove the clamp to above exp2(-127) if you're sure you're not going to input any values below that
    vec3  mantissaPart = clamp((128.0 / 255.0) * exp2(-exponentPart) * rgb, 0.0, 1.0);
          exponentPart = clamp(exponentPart / 255.0 + (127.0 / 255.0), 0.0, 1.0);

    return vec4(mantissaPart, exponentPart);
}

vec3 DecodeRGBE8(vec4 rgbe) {
    const float add = log2(255.0 / 128.0) - 127.0;
    return exp2(rgbe.a * 255.0 + add) * rgbe.rgb;
}

// Octahedral Unit Vector encoding
// Intuitive, fast, and has very little error.
vec2 EncodeUnitVector(vec3 vector) {
	// Scale down to octahedron, project onto XY plane
	vector.xy /= abs(vector.x) + abs(vector.y) + abs(vector.z);
	// Reflect -Z hemisphere folds over the diagonals
	return vector.z <= 0.0 ? (1.0 - abs(vector.yx)) * vec2(vector.x >= 0.0 ? 1.0 : -1.0, vector.y >= 0.0 ? 1.0 : -1.0) : vector.xy;
}

vec3 DecodeUnitVector(vec2 encoded) {
	// Exctract Z component
	vec3 vector = vec3(encoded, 1.0 - abs(encoded.x) - abs(encoded.y));
	// Reflect -Z hemisphere folds over the diagonals
	float t = max(-vector.z, 0.0);
	vector.xy += vec2(vector.x >= 0.0 ? -t : t, vector.y >= 0.0 ? -t : t);
	// normalize and return
	return normalize(vector);
}