#version 330
#extension GL_ARB_separate_shader_objects : require

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;

// === Uniforms ===
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) out vec4 vertexColor;

void main() {
    
    vec3 pos = Position;

    vertexColor = Color;

    bool isGUI = ProjMat[3].x == -1;

    ivec4 colorInt = ivec4(Color * 255);

    if(isGUI) {

        // Hide the scoreboard background
        if((colorInt == vec4(0, 0, 0, 102) || colorInt == vec4(0, 0, 0, 76))) {
            vertexColor.a = 0;
        }
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}
