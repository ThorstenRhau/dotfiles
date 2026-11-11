// Cursor shape pulse: when the cursor changes shape in place, for example
// block to bar on entering Neovim's insert mode, an outline of the new
// cursor grows outward and fades.
//
// iPreviousCursorStyle is overwritten on every terminal update in Ghostty
// 1.4, so this detects a shape change from the cursor size instead:
// iPreviousCursor keeps the old rectangle until the cursor changes again.

const float DURATION = 0.3;         // Seconds.
const float GROW = 0.75;            // Final distance, in cursor heights.
const float THICKNESS = 2.0;        // Outline thickness in pixels.
const float MAX_ALPHA = 0.7;
const float MIN_RATIO = 2.5;        // Size ratio that counts as a new shape.
                                    // Above 2 so wide characters do not count.

float sdBox(vec2 p, vec2 h) {
    vec2 d = abs(p) - h;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec2 center(vec4 c) {
    return c.xy + vec2(0.5, -0.5) * c.zw;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    // Unfocused surfaces stop animating, so a pulse there would freeze. The
    // cursor also changes shape when focus changes (hollow block while
    // unfocused); focus-ring.glsl covers that moment.
    float t = (iTime - iTimeCursorChange) / DURATION;
    if (iFocus == 0 || t >= 1.0 || abs(iTimeCursorChange - iTimeFocus) < 0.1) return;

    vec4 cur = iCurrentCursor;
    vec4 prev = iPreviousCursor;
    vec2 ratio = max(cur.zw, prev.zw) / max(min(cur.zw, prev.zw), vec2(1.0));
    float cellHeight = max(cur.w, prev.w);

    // Same spot (Esc in Neovim also moves one cell left), different shape.
    bool inPlace = distance(center(cur), center(prev)) < cellHeight;
    if (!inPlace || max(ratio.x, ratio.y) < MIN_RATIO) return;

    float eased = 1.0 - pow(1.0 - t, 3.0);
    float radius = GROW * cellHeight * eased;
    float ring = abs(sdBox(fragCoord - center(cur), 0.5 * cur.zw) - radius);
    float cover = clamp(0.5 * THICKNESS + 0.5 - ring, 0.0, 1.0);
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb, cover * MAX_ALPHA * (1.0 - t));
}
