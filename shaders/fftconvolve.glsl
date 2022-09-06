#if AXIS == 1
    layout (local_size_x = 1, local_size_y = 1024, local_size_z = 1) in;
    const ivec3 workGroups = ivec3(1024, 1, 1);
#else
    layout (local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;
    const ivec3 workGroups = ivec3(1, 1024, 1);
#endif

layout (rgba32f) uniform image2D colorimg3;
layout (rgba32f) uniform image2D colorimg4;

uniform sampler2D colortex3;
uniform sampler2D colortex4;

#include "/lib/universal/universal.glsl"

shared vec3[1024] fft_re;
shared vec3[1024] fft_im;

void main() {
    uvec2 invocationID = gl_GlobalInvocationID.xy;
	int shifted = (int(invocationID[AXIS]) + SIZE / 2) % SIZE;
    fft_re[shifted] = imageLoad(colorimg3, ivec2(invocationID)).rgb;
    fft_im[shifted] = imageLoad(colorimg4, ivec2(invocationID)).rgb;

    memoryBarrierShared();
    barrier();

    ivec2 point = ivec2(invocationID.xy) - ivec2(SIZE) / 2;

    for(int i = 2; i <= SIZE; i <<= 1) {
        int base   = int(floor(int(invocationID[AXIS]) / i)) * (i / 2);
        int offset = int(invocationID[AXIS]) % (i / 2);
        int index0 = base + offset;
        int index1 = index0 + (SIZE / 2);

        #ifdef IFFT
            complexVec3 twiddle = complexExp(complexVec3(vec3(0.0), vec3(-2.0 * pi * int(invocationID[AXIS]) / i)));
        #else
            complexVec3 twiddle = complexExp(complexVec3(vec3(0.0), vec3( 2.0 * pi * int(invocationID[AXIS]) / i)));
        #endif

        complexVec3 fft_z = complexAdd(
            vectorsToComplex(fft_re[index0], fft_im[index0]), 
            complexMul(vectorsToComplex(fft_re[index1], fft_im[index1]), twiddle)
        );

        memoryBarrierShared();
        barrier();

        mat2x3 fft_comp = complexToMatrix(fft_z);

        fft_re[invocationID[AXIS]] = fft_comp[0];
        fft_im[invocationID[AXIS]] = fft_comp[1];

        memoryBarrierShared();
        barrier();
    }

    #ifdef IFFT
        fft_re[shifted] /= SIZE;
        fft_im[shifted] /= SIZE;
    #endif

    imageStore(colorimg3, ivec2(invocationID.xy), vec4(fft_re[shifted], 0.0));
    imageStore(colorimg4, ivec2(invocationID.xy), vec4(fft_im[shifted], 0.0));
}