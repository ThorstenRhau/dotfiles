// Focus ring: when a surface gains focus, a rounded outline shrinks onto
// the cursor so it is easy to find. Ghostty also counts a return from
// another app as gaining focus.
//
// Dimming unfocused splits is left to Ghostty's unfocused-split-opacity,
// which skips single panes; a shader cannot tell whether splits exist.

const float DURATION = 0.35;    // Seconds for the ring to reach the cursor.
const float RADIUS = 3.0;       // Start distance, in cursor heights.
const float THICKNESS = 2.0;    // Ring thickness in pixels.
const float MAX_ALPHA = 0.8;

float sdBox(vec2 p, vec2 h) {
    vec2 d = abs(p) - h;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    float t = (iTime - iTimeFocus) / DURATION;
    if (iFocus == 0 || t >= 1.0) return;

    vec2 h = 0.5 * iCurrentCursor.zw;
    vec2 center = iCurrentCursor.xy + vec2(h.x, -h.y);
    float eased = 1.0 - pow(1.0 - t, 3.0);
    float radius = RADIUS * iCurrentCursor.w * (1.0 - eased);
    float ring = abs(sdBox(fragCoord - center, h) - radius);
    float cover = clamp(0.5 * THICKNESS + 0.5 - ring, 0.0, 1.0);
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb, cover * MAX_ALPHA * (1.0 - t));
}
