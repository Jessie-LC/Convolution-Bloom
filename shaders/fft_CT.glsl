layout (local_size_x = 512, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1024, 1, 1);

layout (rgba32f) uniform image2D colorimg1;
layout (rgba32f) uniform image2D colorimg2;

uniform sampler2D colortex1;
uniform sampler2D colortex2;

/*
This code is licensed under the GPL 3.0 license.

https://github.com/bane9/OpenGLFFT/blob/main/LICENSE
https://github.com/bane9/OpenGLFFT
*/

#include "/lib/universal/universal.glsl"

const int logTwoSize = 10;

shared vec3[1024] fft_re;
shared vec3[1024] fft_im;

vec3 pixelBufferReal[32];
vec3 pixelBufferImag[32];

void Sync() {
    memoryBarrierShared();
    barrier();
}

uint ReverseBits(uint num) {
    uint count = 31u;

    uint reverseNum = num;

    num >>= 1;
    while(num != 0) {
        reverseNum <<= 1;
        reverseNum |= num & 1;

        num >>= 1;
        count--;
    }

    reverseNum <<= count;

    return reverseNum;
}

uint IndexMap(uint threadId, uint currentIteration, uint N) {
    return ((threadId & (N - (1u << currentIteration))) << 1) | (threadId & ((1u << currentIteration) - 1));
}

uint TwiddleMap(uint threadId, uint currentIteration, uint N) {
    return (threadId & (N / (1u << (logTwoSize - currentIteration)) - 1)) * (1u << (logTwoSize - currentIteration)) >> 1;
}

complexVec3 Twiddle(uint twiddleMap, uint N, bool isReverse) {
    return complexExp(complexVec3(vec3(0.0), vec3(float(int(!isReverse) * 2 - 1) * 2.0 * pi * int(twiddleMap) / int(N))));
}

void FFT_Radix2(int btid, int g_offset, int N, bool isReverse) {
    for(int i = 0; i < logTwoSize; ++i) {
        for(int j = btid; j < btid + g_offset; ++j) {
            uint even = IndexMap(uint(j), uint(i), uint(N));
            uint odd  = even + (1u << uint(i));

            uint twiddleMap = TwiddleMap(uint(j), uint(i), uint(N));
            complexVec3 twiddle = Twiddle(twiddleMap, uint(N), isReverse);

            complexVec3 fft_Even = complexAdd(
                vectorsToComplex(fft_re[even], fft_im[even]), 
                complexMul(vectorsToComplex(fft_re[odd], fft_im[odd]), twiddle)
            );
            complexVec3 fft_Odd  = complexSub(
                vectorsToComplex(fft_re[even], fft_im[even]), 
                complexMul(vectorsToComplex(fft_re[odd], fft_im[odd]), twiddle)
            );

            mat2x3 fft_compEven = complexToMatrix(fft_Even);
            mat2x3 fft_compSub  =  complexToMatrix(fft_Odd);

            fft_re[odd]  =  fft_compSub[0];
            fft_im[odd]  =  fft_compSub[1];
            fft_re[even] = fft_compEven[0];
            fft_im[even] = fft_compEven[1];
        }

        Sync();
    }
}

const int clzSize = 22;

void LoadStage0(int btid, int g_offset, int scanline) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        int j = int(ReverseBits(i) >> uint(clzSize));

        pixelBufferReal[i - btid * 2] = imageLoad(colorimg1, ivec2(j, scanline)).rgb;
        pixelBufferImag[i - btid * 2] = vec3(0.0);
    }
}
void LoadStage1_2(int btid, int g_offset, int scanline) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        int j = int(ReverseBits(i) >> uint(clzSize));

        pixelBufferReal[i - btid * 2] = imageLoad(colorimg1, ivec2(scanline, j)).rgb;
        pixelBufferImag[i - btid * 2] = imageLoad(colorimg2, ivec2(scanline, j)).rgb;
    }
}
void LoadStage3(int btid, int g_offset, int scanline) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        int j = int(ReverseBits(i) >> uint(clzSize));

        pixelBufferReal[i - btid * 2] = imageLoad(colorimg1, ivec2(j, scanline)).rgb;
        pixelBufferImag[i - btid * 2] = imageLoad(colorimg2, ivec2(j, scanline)).rgb;
    }
}
void StoreStage0(int btid, int g_offset, int scanline) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        ivec2 idx = ivec2(i, scanline);

        imageStore(colorimg1, idx, vec4(pixelBufferReal[i - btid * 2], 0.0));
        imageStore(colorimg2, idx, vec4(pixelBufferImag[i - btid * 2], 0.0));
    }
}
void StoreStage1_2(int btid, int g_offset, int scanline, float N) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        ivec2 idx = ivec2(scanline, i);

        imageStore(colorimg1, idx, vec4(pixelBufferReal[i - btid * 2] * N, 0.0));
        imageStore(colorimg2, idx, vec4(pixelBufferImag[i - btid * 2] * N, 0.0));
    }
}
void StoreStage3(int btid, int g_offset, int scanline, float N) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        ivec2 idx = ivec2(i, scanline);

        imageStore(colorimg1, idx, vec4(pixelBufferReal[i - btid * 2] * N, 0.0));
        imageStore(colorimg2, idx, vec4(pixelBufferImag[i - btid * 2] * N, 0.0));
    }
}
void LoadIntoShared(int btid, int g_offset) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        int j = int(ReverseBits(i) >> uint(clzSize));

        fft_re[i] = pixelBufferReal[i - btid * 2];
        fft_im[i] = pixelBufferImag[i - btid * 2];
    }
}
void LoadFromShared(int btid, int g_offset) {
    for(int i = btid * 2; i < btid * 2 + g_offset * 2; ++i) {
        int j = int(ReverseBits(i) >> uint(clzSize));

        pixelBufferReal[i - btid * 2] = fft_re[i];
        pixelBufferImag[i - btid * 2] = fft_im[i];
    }
}

void main() {
    switch(ImageStage) {
        case 0: {
            int g_offset = SIZE / 2 / 512;
            int btid = int(g_offset * gl_LocalInvocationID.x);

            LoadStage0(btid, g_offset, int(gl_WorkGroupID.x));
            Sync();

            LoadIntoShared(btid, g_offset);
            Sync();

            FFT_Radix2(btid, g_offset, SIZE, false);
            Sync();

            LoadFromShared(btid, g_offset);
            Sync();

            StoreStage0(btid, g_offset, int(gl_WorkGroupID.x));
            Sync();

            return;
        }
        case 1: 
        case 2: {
            int g_offset = SIZE / 2 / 512;
            int btid = int(g_offset * gl_LocalInvocationID.x);
			float divisor = (ImageStage == 2) ? 1.0 / float(SIZE) : 1.0;
			bool isInverse = ImageStage == 2;

            LoadStage1_2(btid, g_offset, int(gl_WorkGroupID.x));
            Sync();

            LoadIntoShared(btid, g_offset);
            Sync();

            FFT_Radix2(btid, g_offset, SIZE, isInverse);
            Sync();

            LoadFromShared(btid, g_offset);
            Sync();

            StoreStage1_2(btid, g_offset, int(gl_WorkGroupID.x), divisor);
            Sync();

            return;
        }
        case 3: {
            int g_offset = SIZE / 2 / 512;
            int btid = int(g_offset * gl_LocalInvocationID.x);

            LoadStage3(btid, g_offset, int(gl_WorkGroupID.x));
            Sync();

            LoadIntoShared(btid, g_offset);
            Sync();

            FFT_Radix2(btid, g_offset, SIZE, true);
            Sync();

            LoadFromShared(btid, g_offset);
            Sync();

            StoreStage3(btid, g_offset, int(gl_WorkGroupID.x), 1.0 / SIZE);
            Sync();

            return;
        }
    }
}