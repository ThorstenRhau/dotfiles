// Smooth caret: small cursor moves, such as typing, deleting, hjkl and line
// changes, glide to the new cell instead of jumping, like Word's smooth
// typing. Text still appears at once; only the cursor animates. Larger jumps
// are left to cursor-warp.glsl.
//
// During the glide the shader hides the real cursor and draws one at the
// in-between position:
// - Bar and underline: the cursor cell is restored from the pixel beside the
//   cursor (left of a bar, above an underline).
// - Block: with cursor-color = cell-foreground and cursor-text =
//   cell-background, the cursor swaps the cell's two colors, so
//   F + B - pixel undoes or applies the swap. B is read from the top pixel
//   row just left of the cursor cell, which is rarely part of a glyph and
//   carries line highlights such as Neovim's cursorline.

const float GLIDE = 0.07;    // Seconds from the old cell to the new one.
const float MAX_STEP = 1.5;  // Cursor heights; cursor-warp's
                             // THRESHOLD_MIN_DISTANCE takes over above it.

// Fraction of the pixel at p covered by rectangle r (left, top, width,
// height, y up). Gives the moving cursor smooth subpixel edges.
float coverage(vec2 p, vec4 r) {
    vec2 lo = vec2(r.x, r.y - r.w);
    vec2 hi = vec2(r.x + r.z, r.y);
    vec2 c = clamp(min(p - lo, hi - p) + 0.5, 0.0, 1.0);
    return c.x * c.y;
}

vec3 pixel(vec2 p) {
    return texture(iChannel0, p / iResolution.xy).rgb;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    vec4 cur = iCurrentCursor;
    vec4 prev = iPreviousCursor;
    float t = (iTime - iTimeCursorChange) / GLIDE;
    float moved = distance(cur.xy, prev.xy);

    if (iFocus == 0 || iCursorVisible == 0 || t >= 1.0) return;
    if (cur.zw != prev.zw || moved == 0.0 || moved > MAX_STEP * cur.w) return;

    int style = iCurrentCursorStyle;
    bool block = style == CURSORSTYLE_BLOCK;
    if (!block && style != CURSORSTYLE_BAR && style != CURSORSTYLE_UNDERLINE) return;

    float eased = 1.0 - pow(1.0 - t, 3.0);
    vec4 moving = vec4(mix(prev.xy, cur.xy, eased), cur.zw);

    vec3 F = iCurrentCursorColor.rgb;
    vec3 B = pixel(cur.xy + vec2(-0.5, -0.5));
    vec3 color = fragColor.rgb;

    // Hide the real cursor. It sits on whole pixels, so a hard test is exact.
    if (coverage(fragCoord, cur) > 0.5) {
        if (block) {
            color = F + B - color;
        } else if (style == CURSORSTYLE_BAR) {
            color = pixel(vec2(cur.x - 0.5, fragCoord.y));
        } else {
            color = pixel(vec2(fragCoord.x, cur.y + 0.5));
        }
    }

    // Draw the gliding cursor.
    float a = coverage(fragCoord, moving);
    vec3 drawn = block ? F + B - color : F;
    fragColor.rgb = clamp(mix(color, drawn, a), 0.0, 1.0);
}
