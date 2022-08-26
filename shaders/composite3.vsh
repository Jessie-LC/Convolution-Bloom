#version 450 compatibility

out vec2 textureCoordinate;

void main() {
    gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);

    textureCoordinate = gl_Vertex.xy;
}