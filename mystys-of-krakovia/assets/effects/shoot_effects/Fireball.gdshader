// Shader type changed to 'spatial' for 3D objects
shader_type spatial;

// Render mode adapted for a fire/glow effect
// blend_add: Colors add to what's behind them (good for light)
// unshaded: The object will not be affected by scene lighting; it will glow
// depth_draw_never: Helps with transparency sorting issues
render_mode blend_add, unshaded, depth_draw_never;

// Uniforms are the same
uniform float time : hint_range(0.0, 10.0);
uniform float frame_scope : hint_range(0.1, 10.0) = 3.0;
uniform bool use_system_time = false;
uniform float time_accel : hint_range(0.0, 10.0, 0.1) = 5.0;

// The noise function is unchanged
float snoise(vec3 uv, float res)
{
    const vec3 s = vec3(1e0, 1e2, 1e3);
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
    // We use the mesh's UV coordinates directly.
    // The calculation for 'p' makes the effect centered on the UV map.
    vec2 p = 2.0 * UV - 1.0;
    float color = 3.0 - (frame_scope * length(2.0 * p));

    vec3 coord = vec3(atan(p.x, p.y) / 6.2832 + 0.5, length(p) * 0.4, 0.5);

    for (int i = 1; i <= 8; i++)
    {
        float power = pow(2.0, float(i));
        if (use_system_time) {
            color += (1.5 / power) * snoise(coord + vec3(0.0, -TIME * 0.05 * time_accel, TIME * 0.01 * time_accel), power * 16.0);
        } else {
            color += (1.5 / power) * snoise(coord + vec3(0.0, -time * 0.05, time * 0.01), power * 16.0);
        }
    }

    // Instead of setting COLOR, we set 3D properties:
    // ALBEDO: The base color of the material.
    // EMISSION: The light the material gives off (makes it glow).
    // ALPHA: The transparency of the material.
    if (color < 0.2) { // Increased threshold for a cleaner cutoff
        ALPHA = 0.0;
    } else {
        vec3 colortemp = vec3(color, pow(max(color, 0.0), 2.0) * 0.4, pow(max(color, 0.0), 3.0) * 0.15);

        // Assign the calculated colors to the 3D material properties
        ALBEDO = colortemp;
        EMISSION = colortemp; // Make it glow!
        ALPHA = clamp(length(colortemp), 0.0, 1.0); // Set transparency
    }
}