#version 330
#extension GL_ARB_separate_shader_objects : require

#include <color_util.glsl>
#include <shared_data_ids.glsl>

#ifdef GLINT
#include <minecraft:globals.glsl>
#endif
#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>

uniform sampler2D Sampler0;

#ifdef GLINT
uniform sampler2D GlintSampler;
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
#endif
layout(location = 2) in vec4 vertexColor;
layout(location = 5) in vec2 texCoord0;
#ifdef GLINT
layout(location = 6) in vec2 texCoordGlint;
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

#define IN_OUT in
#include <ravengard_item_io.glsl>

#ifndef OIT_ALPHA_ONLY
vec4 calculateFinalColor(vec4 color) {
    #ifdef GLINT
    vec4 glintColor = GlintAlpha * texture(GlintSampler, texCoordGlint);
    // Matches BlendFunction.GLINT
    color.rgb += glintColor.rgb * glintColor.rgb;
    #endif

    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif

    return apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
}
#endif

void main() {
    vec4 sampledColor = texture(Sampler0, texCoord0);
    vec4 color = sampledColor * vertexColor * ColorModulator;

    // Emissive textures
    if (shouldApplyEmissives(sampledColor.a)) {
        color = vec4(sampledColor.rgb, 1.0);
    }

    // 50% Opaque Emissive textures
    if (shouldApplyHalfOpaqueEmissives(sampledColor.a)) {
        color = vec4(sampledColor.rgb, 0.5);
    }

    #ifndef OIT_ALPHA_ONLY
    if (isOverlay == 1)
    {
        // RGB is multiplied by alpha channel then truncated, so Alpha must be 1.0 to preserve precision
        // data1.rgb = marker
        // data2.rg = texture offset
        // data3.rg = texture size
        
        // Write the important data to the output texture
        if(ivec2(gl_FragCoord.xy) == ivec2(0, 0)) {
            
            // Data 1 - Marker
            fragColor.rgb = vec3(0xFE, 0xFD, 0x02) / 255.0; // Marker to indicate this is an overlay texture
            fragColor.a = 1.0;
            return;
        } else if(ivec2(gl_FragCoord.xy) == ivec2(1, 0)) {

            // Data 2 - Texture offset
            fragColor.rgb = dyeColor.rgb;
            fragColor.a = 1.0;
            return;

        } else if(ivec2(gl_FragCoord.xy) == ivec2(0, 1)) {
            
            // Data 3 - Texture size

            // Calculate texture size
            // Undo interpolation to get top left and bottom right UVs
            vec2 uv00 = uvTopLeft.xy / uvTopLeft.z;
            vec2 uv11 = uvBottomRight.xy / uvBottomRight.z;

            // Calculate exact texture size in pixels
            vec2 uvSizeInPixels = (uv11 - uv00) * textureSize(Sampler0, 0);

            // Store data
            fragColor.rg = uvSizeInPixels / 255.0; // Calculated texture size
            fragColor.b = 0.0;
            fragColor.a = 1.0;
            return;
        }

        color = sampledColor;
    }
    #endif

    if (color.a < 0.1) {
        discard;
    }

    #ifdef GLINT
    color.a = max(color.a, GlintAlpha);
    #endif

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}
