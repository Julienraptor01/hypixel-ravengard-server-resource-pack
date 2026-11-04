#version 330
#extension GL_ARB_shader_draw_parameters : enable

#moj_import <color_util.glsl>
#moj_import <ui_helpers.glsl>
#moj_import <text_shadow.glsl>
#moj_import <ravengard_config.glsl>

// === Uniforms ===
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>
uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

#define IN_OUT out
#moj_import <ravengard_text_io.glsl>

#moj_import <ravengard_text.glsl>

void main() {

    // Initialize default values
    pos = Position;
    int cornerID = CORNER_ID;
    corner = corners[cornerID];
    vertexColor = Color;
    texCoord0 = UV0;
    spellPixelCoord = ivec3(-1);
    dataID = DATA_ID_DEFAULT;
    cropCoords = vec4(-100000);
    cutoutCoords = vec4(-100000);
    direction = vec2(0);
    sampleScale = -1.0;
    sampleBounds = vec4(0.0);
    sphericalVertexDistance = 0.0;
    cylindricalVertexDistance = 0.0;

    // Send character bounding box data to fragment shader, using Z to undo interpolation from other vertices
    uvTopLeft = cornerID == 0 ? vec3(UV0.xy, 1.0) : vec3(0.0);
    uvBottomRight = cornerID == 2 ? vec3(UV0.xy, 1.0) : vec3(0.0);

    if (ProjMat[3].x == -1) {
        ravengardText();
    } else {
        sphericalVertexDistance = fog_spherical_distance(Position);
        cylindricalVertexDistance = fog_cylindrical_distance(Position);
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}