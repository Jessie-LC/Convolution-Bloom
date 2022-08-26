float square(in float x) {
    return _square(x);
}
int square(in int x) {
    return _square(x);
}
vec2 square(in vec2 x) {
    return _square(x);
}
vec3 square(in vec3 x) {
    return _square(x);
}
vec4 square(in vec4 x) {
    return _square(x);
}

float cube(in float x) {
    return _cube(x);
}
int cube(in int x) {
    return _cube(x);
}
vec2 cube(in vec2 x) {
    return _cube(x);
}
vec3 cube(in vec3 x) {
    return _cube(x);
}
vec4 cube(in vec4 x) {
    return _cube(x);
}

float pow5(in float x) {
    return _pow5(x);
}
int pow5(in int x) {
    return _pow5(x);
}
vec2 pow5(in vec2 x) {
    return _pow5(x);
}
vec3 pow5(in vec3 x) {
    return _pow5(x);
}
vec4 pow5(in vec4 x) {
    return _pow5(x);
}

float saturate(in float x) {
    return _saturate(x);
}
int saturate(in int x) {
    return _saturateInt(x);
}
vec2 saturate(in vec2 x) {
    return _saturate(x);
}
vec3 saturate(in vec3 x) {
    return _saturate(x);
}
vec4 saturate(in vec4 x) {
    return _saturate(x);
}

float minof(vec2 x) { 
    return min(x.x, x.y); 
}
float minof(vec3 x) { 
    return min(min(x.x, x.y), x.z); 
}
float minof(vec4 x) { 
    x.xy = min(x.xy, x.zw); return min(x.x, x.y); 
}

float maxof(vec2 x) { 
    return max(x.x, x.y); 
}
float maxof(vec3 x) { 
    return max(max(x.x, x.y), x.z); 
}
float maxof(vec4 x) { 
    x.xy = max(x.xy, x.zw); return max(x.x, x.y); 
}

float rcp(in int x) {
    float y = float(x);
    return _rcp(y);
}
float rcp(in float x) {
    return _rcp(x);
}
vec2 rcp(in vec2 x) {
    return _rcp(x);
}
vec3 rcp(in vec3 x) {
    return _rcp(x);
}
vec4 rcp(in vec4 x) {
    return _rcp(x);
}

float log10(in float x) {
    return _log10(x, 10.0);
}

int log10(in int x) {
    return int(_log10(x, 10.0));
}

vec2 log10(in vec2 x) {
    return _log10(x, 10.0);
}

vec3 log10(in vec3 x) {
    return _log10(x, 10.0);
}

vec4 log10(in vec4 x) {
    return _log10(x, 10.0);
}

float linearstep(in float x, float low, float high) {
    float data = x;
    float mapped = (data-low)/(high-low);

    return saturate(mapped);
}

vec2 linearstep(in vec2 x, float low, float high) {
    vec2 data = x;
    vec2 mapped = (data-low)/(high-low);

    return saturate(mapped);
}

vec3 linearstep(in vec3 x, float low, float high) {
    vec3 data = x;
    vec3 mapped = (data-low)/(high-low);

    return saturate(mapped);
}

vec4 linearstep(in vec4 x, float low, float high) {
    vec4 data = x;
    vec4 mapped = (data-low)/(high-low);

    return saturate(mapped);
}

vec2 sincos(float x) { return vec2(sin(x), cos(x)); }