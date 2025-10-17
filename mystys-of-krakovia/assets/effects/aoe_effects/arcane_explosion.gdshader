shader_type spatial;

uniform vec4 color_start = vec4(0.6, 0.2, 1.0, 1.0);  // bright purple
uniform vec4 color_end   = vec4(0.6, 0.2, 1.0, 0.5);  // semi-transparent purple
uniform float progress = 0.0;

void fragment() {
    vec2 uv_centered = UV - vec2(0.5);
    float dist = length(uv_centered);

    // create radial ring
    float ring = smoothstep(progress - 0.05, progress, dist) *
                 (1.0 - smoothstep(progress, progress + 0.05, dist));

    ALBEDO = color_start.rgb;

    // keep ring visible by blending alpha
    ALPHA = ring * mix(color_start.a, color_end.a, progress);
}
