#version 330

#moj_import <color_util.glsl>
#moj_import <texture_sampling.glsl>
#moj_import <text_shadow.glsl>
#moj_import <ravengard_config.glsl>

// === Uniforms ===
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:fog.glsl>
uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

#define IN_OUT in
#moj_import <ravengard_text_io.glsl>

out vec4 fragColor;

#moj_import <ravengard_text_frag.glsl>

void main() {
    fragColor = apply_fog(shadeText(), sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}