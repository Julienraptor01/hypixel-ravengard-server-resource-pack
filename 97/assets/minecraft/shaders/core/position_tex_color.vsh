#version 330
#extension GL_ARB_separate_shader_objects : require
#extension GL_ARB_shader_draw_parameters : enable

#include <ui_helpers.glsl>
#include <color_util.glsl>
#include <ravengard_config.glsl>

// === Uniforms ===
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:globals.glsl>
uniform sampler2D Sampler0;

layout(location = 0) in vec3 Position;
layout(location = 1) in vec2 UV0;
layout(location = 2) in vec4 Color;

layout(location = 0) out vec2 texCoord0;
layout(location = 1) out vec4 vertexColor;

// Vertex outputs the handlers populate
vec3 pos;

#include <ravengard_ui.glsl>

void main() {

    pos = Position;
    texCoord0 = UV0;
    vertexColor = Color;

    if(ProjMat[3].x == -1) { // isGUI
        ravengardUI();
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}