// Cursor effects, drawn in one pass. Ghostty runs each custom-shader file as
// a separate full-screen pass and, with custom-shader-animation = true,
// redraws the focused surface about every 8 ms, so one file reads and writes
// the screen once instead of once per effect.
//
// Effects, in the order they are applied:
// 1. Smooth caret: small moves, such as typing, deleting, hjkl and line
//    changes, glide to the new cell instead of jumping. Text still appears at
//    once; only the cursor animates.
// 2. Cursor warp: larger jumps leave a Neovide-like trail.
// 3. Shape pulse: when the cursor changes shape in place, for example block
//    to bar on entering Neovim's insert mode, an outline grows and fades.
// 4. Focus ring: when the surface gains focus, an outline shrinks onto the
//    cursor. Ghostty also counts a return from another app as gaining focus.
//
// Coordinates (Ghostty 1.4 on Metal): y points down in fragCoord and in the
// cursor rectangles. A cursor rectangle is (left, bottom, width, height), so
// its top edge is at y - height.
//
// Colors come from the theme through iCurrentCursorColor, iCursorText and
// iForegroundColor, so the config must not override cursor-color or
// cursor-text with cell-foreground or cell-background.
//
// Dimming unfocused splits is left to Ghostty's unfocused-split-opacity,
// which skips single panes; a shader cannot tell whether splits exist.

// --- Shared helpers ---

vec3 pixel(vec2 p) {
    return texture(iChannel0, p / iResolution.xy).rgb;
}

float sdBox(vec2 p, vec2 h) {
    vec2 d = abs(p) - h;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec2 cursorCenter(vec4 c) {
    return c.xy + vec2(0.5, -0.5) * c.zw;
}

// Fraction of the pixel at p covered by cursor rectangle r. Gives a moving
// cursor smooth subpixel edges.
float coverage(vec2 p, vec4 r) {
    vec2 lo = vec2(r.x, r.y - r.w);
    vec2 hi = vec2(r.x + r.z, r.y);
    vec2 c = clamp(min(p - lo, hi - p) + 0.5, 0.0, 1.0);
    return c.x * c.y;
}

// Where c lies between colors a (0) and b (1). On a cell drawn in two
// colors, this is the glyph coverage of the pixel.
float between(vec3 c, vec3 a, vec3 b) {
    vec3 ab = b - a;
    return clamp(dot(c - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0);
}

// Cursor-colored outline at the given distance outside rectangle r.
vec3 outline(vec3 color, vec2 p, vec4 r, float radius, float thickness, float alpha) {
    float ring = abs(sdBox(p - cursorCenter(r), 0.5 * r.zw) - radius);
    float cover = clamp(0.5 * thickness + 0.5 - ring, 0.0, 1.0);
    return mix(color, iCurrentCursorColor.rgb, cover * alpha);
}

// The cursor's longer side: the cell height for a block or bar, the cell
// width for an underline. Ghostty trims cursor sprites to their drawn
// pixels, so an underline's height is only its thickness. Move thresholds
// use this so the glide and the warp hand over at the same distance for
// every style; for an underline a line change counts as a large jump.
float cursorSize(vec4 c) {
    return max(c.z, c.w);
}

// iPreviousCursor is all zeros until a surface's cursor first changes.
bool hasPreviousCursor() {
    return iPreviousCursor.zw != vec2(0.0);
}

// --- 1. Smooth caret ---
//
// During the glide the real cursor is hidden and one is drawn at the
// in-between position:
// - Block: the cursor cell is drawn in the cursor color with cursor-text
//   glyphs, so between() recovers each pixel's glyph coverage, and the cell
//   is repainted with background B and the foreground color. B is read from
//   the top pixel row of the neighboring cell, which is rarely part of a
//   glyph and carries line highlights such as Neovim's cursorline.
// - Bar and underline: the cursor cell is restored from the pixel beside the
//   cursor (left of a bar, above an underline).
// - The neighbor is the cell to the left, or the one to the right in column
//   0, where the left side is window padding without line highlights.
//   Column 0 is the only column whose left edge is less than a cell width
//   from the window edge, because the padding is narrower than a cell.
//
// shortcut: a bar is trimmed to its own thickness, so its cell width is
// taken as half its height. This finds column 0 while the cell is at most
// about twice as tall as it is wide plus the padding, as with MonoLisa.
// A font with a narrower cell makes column 1 count as column 0, which only
// moves the sample to the right neighbor. Upgrade path: a cell-size uniform,
// if Ghostty adds one.
//
// shortcut: a shader cannot read a cell's own text color, so text under the
// hidden and the gliding block uses iForegroundColor for the 70 ms glide;
// syntax-colored text briefly shows in the default foreground. Upgrade path:
// a per-cell color uniform, if Ghostty ever adds one.

const float GLIDE = 0.07;          // Seconds from the old cell to the new one.
const float GLIDE_MAX_STEP = 1.5;  // In cursorSize() units; the warp's
                                   // THRESHOLD_MIN_DISTANCE takes over above it.

vec3 smoothCaret(vec3 color, vec2 p) {
    vec4 cur = iCurrentCursor;
    vec4 prev = iPreviousCursor;
    float t = (iTime - iTimeCursorChange) / GLIDE;
    float moved = distance(cur.xy, prev.xy);

    if (iCursorVisible == 0 || t >= 1.0) return color;
    if (cur.zw != prev.zw || moved == 0.0 || moved > GLIDE_MAX_STEP * cursorSize(cur)) return color;

    int style = iCurrentCursorStyle;
    bool block = style == CURSORSTYLE_BLOCK;
    if (!block && style != CURSORSTYLE_BAR && style != CURSORSTYLE_UNDERLINE) return color;

    float eased = 1.0 - pow(1.0 - t, 3.0);
    vec4 moving = vec4(mix(prev.xy, cur.xy, eased), cur.zw);

    float cellWidth = style == CURSORSTYLE_BAR ? 0.5 * cur.w : cur.z;
    float sideX = cur.x < cellWidth ? cur.x + cur.z + 0.5 : cur.x - 0.5;

    vec3 C = iCurrentCursorColor.rgb;
    vec3 T = iCursorText;
    vec3 F = iForegroundColor;
    vec3 B = pixel(vec2(sideX, cur.y - cur.w + 0.5));

    // Hide the real cursor. It sits on whole pixels, so a hard test is exact.
    if (coverage(p, cur) > 0.5) {
        if (block) {
            color = mix(B, F, between(color, C, T));
        } else if (style == CURSORSTYLE_BAR) {
            color = pixel(vec2(sideX, p.y));
        } else {
            color = pixel(vec2(p.x, cur.y - cur.w - 0.5));
        }
    }

    // Draw the gliding cursor.
    vec3 drawn = block ? mix(C, T, between(color, B, F)) : C;
    return mix(color, drawn, coverage(p, moving));
}

// --- 2. Cursor warp ---
//
// Cursor Warp (Neovide-like) from
// https://github.com/sahaj-b/ghostty-cursor-shaders/blob/9ad9158a93c0de0c045e1c6b27df37da698bc8af/ghostty/cursor_warp.glsl
// Local changes, marked "local:" below:
// - Runs as a function in this combined shader; the unused sRGBToLinear and
//   the commented-out alternative easing functions are left out.
// - TRAIL_COLOR uses the cursor color as is. Ghostty's default macOS
//   alpha-blending (native) works in sRGB, so linearizing made the trail
//   darker than the cursor.
// - effectiveBlur is assigned, not redeclared, in the BLUR < 2.5 branch, so
//   straight moves skip antialiasing as intended.
// - EaseOutCirc squares x - 1 by multiplication; pow() of a negative base is
//   undefined in GLSL.
// - Returns early before the per-pixel setup, and skips a new surface's
//   first move, which would start from the all-zero rectangle in the corner.
// - The minimum trail distance is measured in cursorSize() so an underline
//   does not warp on every one-cell move.
//
// MIT License
//
// Copyright (c) 2026 Sahaj Bhatt
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// --- CONFIGURATION ---
const float DURATION = 0.2; // total animation time
const float TRAIL_SIZE = 0.8; // 0.0 = all corners move together. 1.0 = max smear (leading corners jump instantly)
const float THRESHOLD_MIN_DISTANCE = 1.5; // min distance to show trail (units of cursor height)
const float BLUR = 1.0; // blur size in pixels (for antialiasing)
const float TRAIL_THICKNESS = 1.0;  // 1.0 = full cursor height, 0.0 = zero height, >1.0 = funky aah
const float TRAIL_THICKNESS_X = 0.9;

const float FADE_ENABLED = 0.0; // 1.0 to enable fade gradient along the trail, 0.0 to disable
const float FADE_EXPONENT = 5.0; // exponent for fade gradient along the trail

// EaseOutCirc
float ease(float x) {
    float u = x - 1.0; // local: was pow(x - 1.0, 2.0)
    return sqrt(1.0 - u * u);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfConvexQuad(in vec2 p, in vec2 v1, in vec2 v2, in vec2 v3, in vec2 v4) {
    float s = 1.0;
    float d = dot(p - v1, p - v1);

    d = seg(p, v1, v2, s, d);
    d = seg(p, v2, v3, s, d);
    d = seg(p, v3, v4, s, d);
    d = seg(p, v4, v1, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance, float blurAmount) {
  return 1. - smoothstep(0., normalize(vec2(blurAmount, blurAmount), 0.).x, distance);
}

// Determines animation duration based on a corner's alignment with the move direction(dot product)
// dot_val will be in [-2, 2]
// > 0.5 (1 or 2) = Leading
// > -0.5 (0)     = Side
// <= -0.5 (-1 or -2) = Trailing
float getDurationFromDot(float dot_val, float DURATION_LEAD, float DURATION_SIDE, float DURATION_TRAIL) {
    float isLead = step(0.5, dot_val);
    float isSide = step(-0.5, dot_val) * (1.0 - isLead);

    // Start with trailing duration
    float duration = mix(DURATION_TRAIL, DURATION_SIDE, isSide);
    // Mix in leading duration
    duration = mix(duration, DURATION_LEAD, isLead);
    return duration;
}

vec3 cursorWarp(vec3 color, vec2 fragCoord) { // local: was mainImage
    float baseProgress = iTime - iTimeCursorChange;

    // local: early returns, see header.
    if (baseProgress >= DURATION - 0.001 || !hasPreviousCursor()) return color;

    // normalization & setup(-1, 1 coords)
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    vec2 halfSizeCC = currentCursor.zw * 0.5;
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);
    vec2 halfSizeCP = previousCursor.zw * 0.5;

    float sdfCurrentCursor = getSdfRectangle(vu, centerCC, halfSizeCC);

    float lineLength = distance(centerCC, centerCP);
    float minDist = max(currentCursor.z, currentCursor.w) * THRESHOLD_MIN_DISTANCE; // local: was currentCursor.w, see cursorSize()

    vec3 newColor = color;

    if (lineLength > minDist) {
        // defining corners of cursors

        // Y (Height) with TRAIL_THICKNESS
        float cc_half_height = currentCursor.w * 0.5;
        float cc_center_y = currentCursor.y - cc_half_height;
        float cc_new_half_height = cc_half_height * TRAIL_THICKNESS;
        float cc_new_top_y = cc_center_y + cc_new_half_height;
        float cc_new_bottom_y = cc_center_y - cc_new_half_height;

        // X (Width) with TRAIL_THICKNESS
        float cc_half_width = currentCursor.z * 0.5;
        float cc_center_x = currentCursor.x + cc_half_width;
        float cc_new_half_width = cc_half_width * TRAIL_THICKNESS_X;
        float cc_new_left_x = cc_center_x - cc_new_half_width;
        float cc_new_right_x = cc_center_x + cc_new_half_width;

        vec2 cc_tl = vec2(cc_new_left_x, cc_new_top_y);
        vec2 cc_tr = vec2(cc_new_right_x, cc_new_top_y);
        vec2 cc_bl = vec2(cc_new_left_x, cc_new_bottom_y);
        vec2 cc_br = vec2(cc_new_right_x, cc_new_bottom_y);

        // same thing for previous cursor
        float cp_half_height = previousCursor.w * 0.5;
        float cp_center_y = previousCursor.y - cp_half_height;
        float cp_new_half_height = cp_half_height * TRAIL_THICKNESS;
        float cp_new_top_y = cp_center_y + cp_new_half_height;
        float cp_new_bottom_y = cp_center_y - cp_new_half_height;

        float cp_half_width = previousCursor.z * 0.5;
        float cp_center_x = previousCursor.x + cp_half_width;
        float cp_new_half_width = cp_half_width * TRAIL_THICKNESS_X;
        float cp_new_left_x = cp_center_x - cp_new_half_width;
        float cp_new_right_x = cp_center_x + cp_new_half_width;

        vec2 cp_tl = vec2(cp_new_left_x, cp_new_top_y);
        vec2 cp_tr = vec2(cp_new_right_x, cp_new_top_y);
        vec2 cp_bl = vec2(cp_new_left_x, cp_new_bottom_y);
        vec2 cp_br = vec2(cp_new_right_x, cp_new_bottom_y);

        // calculating durations for every corner
        const float DURATION_TRAIL = DURATION;
        const float DURATION_LEAD = DURATION * (1.0 - TRAIL_SIZE);
        const float DURATION_SIDE = (DURATION_LEAD + DURATION_TRAIL) / 2.0;

        vec2 moveVec = centerCC - centerCP;
        vec2 s = sign(moveVec);

        // dot products for each corner, determining alignment with movement direction
        float dot_tl = dot(vec2(-1., 1.), s);
        float dot_tr = dot(vec2( 1., 1.), s);
        float dot_bl = dot(vec2(-1.,-1.), s);
        float dot_br = dot(vec2( 1.,-1.), s);

        // assign durations based on dot products
        float dur_tl = getDurationFromDot(dot_tl, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);
        float dur_tr = getDurationFromDot(dot_tr, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);
        float dur_bl = getDurationFromDot(dot_bl, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);
        float dur_br = getDurationFromDot(dot_br, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);

        // check direction of horizontal movement
        float isMovingRight = step(0.5, s.x);
        float isMovingLeft  = step(0.5, -s.x);

        // calculate vertical-rail durations
        float dot_right_edge = (dot_tr + dot_br) * 0.5;
        float dur_right_rail = getDurationFromDot(dot_right_edge, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);

        float dot_left_edge = (dot_tl + dot_bl) * 0.5;
        float dur_left_rail = getDurationFromDot(dot_left_edge, DURATION_LEAD, DURATION_SIDE, DURATION_TRAIL);

        float final_dur_tl = mix(dur_tl, dur_left_rail, isMovingLeft);
        float final_dur_bl = mix(dur_bl, dur_left_rail, isMovingLeft);

        float final_dur_tr = mix(dur_tr, dur_right_rail, isMovingRight);
        float final_dur_br = mix(dur_br, dur_right_rail, isMovingRight);

        // calculate progress for each corner based on the duration and time since cursor change
        float prog_tl = ease(clamp(baseProgress / final_dur_tl, 0.0, 1.0));
        float prog_tr = ease(clamp(baseProgress / final_dur_tr, 0.0, 1.0));
        float prog_bl = ease(clamp(baseProgress / final_dur_bl, 0.0, 1.0));
        float prog_br = ease(clamp(baseProgress / final_dur_br, 0.0, 1.0));

        // get the trial corner positions based on progress
        vec2 v_tl = mix(cp_tl, cc_tl, prog_tl);
        vec2 v_tr = mix(cp_tr, cc_tr, prog_tr);
        vec2 v_br = mix(cp_br, cc_br, prog_br);
        vec2 v_bl = mix(cp_bl, cc_bl, prog_bl);

        // DRAWING THE TRAIL
        float sdfTrail = getSdfConvexQuad(vu, v_tl, v_tr, v_br, v_bl);

        // --- FADE GRADIENT CALCULATION ---
        vec2 fragVec = vu - centerCP;

        // project fragment onto movement vector, normalize to [0, 1]
        // 0.0 at tail, 1.0 at head
        // tiny epsilon to avoid division by zero if moveVec is (0,0)
        float fadeProgress = clamp(dot(fragVec, moveVec) / (dot(moveVec, moveVec) + 1e-6), 0.0, 1.0);

        vec4 trail = iCurrentCursorColor; // local: no sRGBToLinear, see header. For custom color: vec4(0.2, 0.6, 1.0, 0.5);

        float effectiveBlur = BLUR;
        if (BLUR < 2.5) {
          // no antialising on horizontal/vertical movement, fixes 'pulse' like thing on end cursor
          float isDiagonal = abs(s.x) * abs(s.y); // 1.0 if diagonal, 0.0 if H/V
          effectiveBlur = mix(0.0, BLUR, isDiagonal); // local: was redeclared
        }
        float shapeAlpha = antialising(sdfTrail, effectiveBlur); // shape mask

        if (FADE_ENABLED > 0.5) {
            // apply fade gradient along the trail
            // float fadeStart = 0.2;
            // float easedProgress = smoothstep(fadeStart, 1.0, fadeProgress);
            // easedProgress = pow(2.0, 10.0 * (fadeProgress - 1.0));
            float easedProgress = pow(fadeProgress, FADE_EXPONENT);
            trail.a *= easedProgress;
        }

        float finalAlpha = trail.a * shapeAlpha;

        // local: blends rgb only; mainImage keeps the background alpha.
        newColor = mix(newColor, trail.rgb, finalAlpha);

        // punch hole on the trail, so current cursor is drawn on top
        newColor = mix(newColor, color, step(sdfCurrentCursor, 0.));

    }

    return newColor;
}

// --- 3. Shape pulse ---
//
// iPreviousCursorStyle is overwritten on every terminal update in Ghostty
// 1.4, so this detects a shape change from the cursor size instead:
// iPreviousCursor keeps the old rectangle until the cursor changes again.

const float PULSE_DURATION = 0.3;   // Seconds.
const float PULSE_GROW = 0.75;      // Final distance, in cursor heights.
const float PULSE_THICKNESS = 2.0;  // Outline thickness in pixels.
const float PULSE_MAX_ALPHA = 0.7;
const float PULSE_MIN_RATIO = 2.5;  // Size ratio that counts as a new shape.
                                    // Above 2 so wide characters do not count.

vec3 shapePulse(vec3 color, vec2 p) {
    // The cursor also changes shape when focus changes (hollow block while
    // unfocused); the focus ring covers that moment.
    float t = (iTime - iTimeCursorChange) / PULSE_DURATION;
    if (t >= 1.0 || abs(iTimeCursorChange - iTimeFocus) < 0.1 || !hasPreviousCursor()) return color;

    vec4 cur = iCurrentCursor;
    vec4 prev = iPreviousCursor;
    vec2 ratio = max(cur.zw, prev.zw) / max(min(cur.zw, prev.zw), vec2(1.0));
    float cellHeight = max(cur.w, prev.w);

    // Same spot (Esc in Neovim also moves one cell left), different shape.
    bool inPlace = distance(cursorCenter(cur), cursorCenter(prev)) < cellHeight;
    if (!inPlace || max(ratio.x, ratio.y) < PULSE_MIN_RATIO) return color;

    float eased = 1.0 - pow(1.0 - t, 3.0);
    return outline(color, p, cur, PULSE_GROW * cellHeight * eased,
                   PULSE_THICKNESS, PULSE_MAX_ALPHA * (1.0 - t));
}

// --- 4. Focus ring ---

const float RING_DURATION = 0.35;  // Seconds for the ring to reach the cursor.
const float RING_RADIUS = 3.0;     // Start distance, in cursor heights.
const float RING_THICKNESS = 2.0;  // Ring thickness in pixels.
const float RING_MAX_ALPHA = 0.8;

vec3 focusRing(vec3 color, vec2 p) {
    // The cursor rectangle is stale while the cursor is hidden.
    float t = (iTime - iTimeFocus) / RING_DURATION;
    if (t >= 1.0 || iCursorVisible == 0) return color;

    float eased = 1.0 - pow(1.0 - t, 3.0);
    return outline(color, p, iCurrentCursor, RING_RADIUS * iCurrentCursor.w * (1.0 - eased),
                   RING_THICKNESS, RING_MAX_ALPHA * (1.0 - t));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    // An unfocused surface redraws only on terminal updates, so an animation
    // there would freeze on whatever frame was drawn last.
    if (iFocus == 0) return;

    vec3 color = smoothCaret(fragColor.rgb, fragCoord);
    color = cursorWarp(color, fragCoord);
    color = shapePulse(color, fragCoord);
    fragColor.rgb = focusRing(color, fragCoord);
}
