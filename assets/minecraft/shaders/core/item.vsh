#version 330
#extension GL_ARB_separate_shader_objects : require
#extension GL_ARB_shader_draw_parameters : enable

#include <color_util.glsl>
#include <ui_helpers.glsl>

#include <minecraft:light.glsl>
#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
layout(location = 4) in ivec2 UV2;
#ifdef GLINT_SPECIAL
layout(location = 5) in vec2 UV3;
#endif
layout(location = 6) in vec3 Normal;

uniform sampler2D Sampler0;
#ifndef OIT_ALPHA_ONLY
uniform sampler2D Sampler2;

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
#endif
layout(location = 2) out vec4 vertexColor;

layout(location = 5) out vec2 texCoord0;
#ifdef GLINT
layout(location = 6) out vec2 texCoordGlint;
#endif

#define IN_OUT out
#include <ravengard_item_io.glsl>

// In 1.21.6, ItemStacks are pre-rendered into a separate internal texture first,
// then get rendered again into the main target by position_tex_color.vsh.
// With oversized_in_gui enabled, the item is pre-rendered to its own separate texture,
// sized to the max display size * the current GUI scale. If the final pre-rendered texture
// would be smaller than 16x16 before GUI scale (or oversized_in_gui is false), it will be
// stitched into the atlas.

// === Menu Pipeline Steps ===
// 1. item.vsh (this file) - Check if this is an overlay texture (cornerColor = 0xFEFD02)
// 2. item.fsh - Get texture offset and calculate texture size. Store as data pixels.
// 3. position_tex_color.vsh - Read the data pixels and move the texture to the correct screen position

void main() {

    isOverlay = 0;
    dyeColor = vec4(0.0);

    // Overlays and Buttons. Used to overlay textures on the inventory screen using itemstacks
    vec4 cornerColor = getCornerColor(Sampler0, UV0);
    int cornerColorID = getColorID(cornerColor.rgb);
    if(cornerColorID == 0xFEFD02) {

        // Mark as overlay
        isOverlay = 1;

        // The dye color is normally inaccessible to position_tex_color, but we can send it using
        // extra space in the oversized texture.
        dyeColor = Color;

        // UV size data, using Z to undo interpolation from other vertices
        // Used to calculate the texture size in the fragment shader
        uvTopLeft = vec3(0.0);
        uvBottomRight = vec3(0.0);
        if (CORNER_ID == 0) {
            uvTopLeft = vec3(UV0.xy, 1.0);
        } else if (CORNER_ID == 2) {
            uvBottomRight = vec3(UV0.xy, 1.0);
        }
    }

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    #ifndef OIT_ALPHA_ONLY
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * sample_lightmap(Sampler2, UV2);
    #else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    #endif
    texCoord0 = UV0;

    #ifdef GLINT
    #ifdef GLINT_SPECIAL
    texCoordGlint = (TextureMat * vec4(UV3, 0.0, 1.0)).xy;
    #else
    texCoordGlint = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
    #endif
    #endif
}
