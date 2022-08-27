#version 450

/*
   Copyright 2022 Jessie Curtis

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/* DRAWBUFFERS:12 */
layout(location = 0) out vec3 color_re;
layout(location = 1) out vec3 color_im;

uniform sampler2D colortex0;

uniform float viewWidth, viewHeight;

in vec2 textureCoordinate;

#include "/lib/universal/universal.glsl"

void main() {
    vec2 coordinate = textureCoordinate;
    vec3 image_lin = SrgbToLinear(texture(colortex0, coordinate).rgb);

    if(coordinate.x > 1.0) {
        image_lin = vec3(0.0);
    }
    if(coordinate.x < 0.0) {
        image_lin = vec3(0.0);
    }
    if(coordinate.y > 1.0) {
        image_lin = vec3(0.0);
    }
    if(coordinate.y < 0.0) {
        image_lin = vec3(0.0);
    }

    color_re = image_lin * pow(dot(lumacoeff_rec709, image_lin) * 2.0, 2.0);
    color_im = vec3(0.0);
}