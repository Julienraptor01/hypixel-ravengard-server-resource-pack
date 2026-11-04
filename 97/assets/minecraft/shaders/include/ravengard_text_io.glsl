layout(location = 4) IN_OUT vec3 pos;
layout(location = 5) IN_OUT vec2 corner;
layout(location = 6) IN_OUT vec3 spellPixelCoord; // Z is whether this is a spell or not (-1 = no, 1 = yes)
layout(location = 7) IN_OUT vec4 cropCoords; // Where the fragment shader should crop to. XY is top left, ZW is bottom right
layout(location = 8) IN_OUT vec4 cutoutCoords; // Where the fragment shader should cut out the deathwall. XY is top left, ZW is bottom right
layout(location = 9) IN_OUT vec2 direction;
layout(location = 10) IN_OUT float sampleScale; // Sharp-filter magnification in screen pixels per texel (0 = plain texture sampling)
layout(location = 11) IN_OUT vec4 sampleBounds; // Samplable texel region for the sharp filter (xy = min, zw = max)
layout(location = 12) IN_OUT vec3 uvTopLeft;
layout(location = 13) IN_OUT vec3 uvBottomRight;

layout(location = 14) flat IN_OUT int dataID;
