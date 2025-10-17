// Shader type for 3D objects
shader_type spatial;

// Render settings for glowing, semi-transparent blood
render_mode blend_add, unshaded, depth_draw_never;

uniform float time : hint_range(0.0, 10.0);
uniform float frame_scope : hint_range(0.1, 10.0) = 3.0;
uniform bool use_system_time = false;
uniform float time_accel : hint_range(0.0, 10.0, 0.1) = 2.0; // slower for blood effect

// Noise function (kept from your original)
float snoise(vec3 uv, float res)
{
    const vec3 s = vec3(1.0, 1e2, 1e3);
    uv *= res;
    vec3 uv0 = floor(mod(uv, res)) * s;
    vec3 uv1 = floor(mod(uv + vec3(1.0), res)) * s;
    vec3 f = fract(uv);
    f = f * f * (3.0 - 2.0 * f);
    vec4 v = vec4(uv0.x + uv0.y + uv0.z, uv1.x + uv0.y + uv0.z,
                  uv0.x + uv1.y + uv0.z, uv1.x + uv1.y + uv0.z);
    vec4 r = fract(sin(v * 1e-1) * 1e3);
    float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
    r = fract(sin((v + uv1.z - uv0.z) * 1e-1) * 1e3);
    float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
    return mix(r0, r1, f.z) * 2.0 - 1.0;
}

void fragment()
{
    vec2 p = 2.0 * UV - 1.0;
    float intensity = 3.0 - (frame_scope * length(2.0 * p));

    vec3 coord = vec3(atan(p.x, p.y) / 6.2832 + 0.5, length(p) * 0.4, 0.5);

    // accumulate layered noise
    for (int i = 1; i <= 8; i++)
    {
        float power = pow(2.0, float(i));
        if (use_system_time) {
            intensity += (1.2 / power) * snoise(coord + vec3(0.0, -TIME * 0.02 * time_accel, TIME * 0.01 * time_accel), power * 16.0);
        } else {
            intensity += (1.2 / power) * snoise(coord + vec3(0.0, -time * 0.02, time * 0.01), power * 16.0);
        }
    }

    if (intensity < 0.1) {
        ALPHA = 0.0; // transparent where intensity is low
    } else {
        // Blood color palette: dark red, with subtle variation
        vec3 bloodColor = vec3(
            clamp(intensity * 0.8, 0.2, 1.0),           // red component
            clamp(intensity * 0.1, 0.0, 0.3),           // green component (dark)
            clamp(intensity * 0.05, 0.0, 0.1)           // blue component (very little)
        );

        ALBEDO = bloodColor;
        EMISSION = bloodColor * 0.8; // makes it glow slightly
        ALPHA = clamp(intensity, 0.0, 0.9); // mostly opaque, but can fade edges
    }
}
