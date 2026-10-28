#version 330
#extension GL_ARB_separate_shader_objects : require

// === Uniforms ===
#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#include <minecraft:fog.glsl>
#endif
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>
#ifdef IS_GUI
#include <minecraft:globals.glsl>
#endif
uniform sampler2D Sampler0;

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
#endif

layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec2 texCoord0;

#ifdef IS_GUI
#include <color_util.glsl>
#include <hypixel_texture_sampling.glsl>
#include <text_shadow.glsl>
#include <ravengard_config.glsl>

#define IN_OUT in
#include <ravengard_text_io.glsl>
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

#ifdef IS_GUI
#include <ravengard_text_frag.glsl>
#endif

void main() {
#ifdef IS_GUI
    // GUI text: full custom Ravengard shading (shadows, minimap, spells, cooldowns, etc.)
    fragColor = shadeText();
#else
    // === Vanilla world / see-through text ===
#ifdef IS_GRAYSCALE
    vec4 texColor = texture(Sampler0, texCoord0).rrrr;
#else
    vec4 texColor = texture(Sampler0, texCoord0);
#endif
    vec4 color = texColor * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }

#ifdef IS_SEE_THROUGH
    fragColor = color;
#else

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else

    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif

    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
    #endif

#endif
#endif
}