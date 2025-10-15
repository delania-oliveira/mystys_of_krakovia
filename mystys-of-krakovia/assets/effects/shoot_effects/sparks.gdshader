shader_type spatial;

uniform vec4 particle_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);

void fragment() {
    float fade = smoothstep(1.0, 0.0, length(UV - vec2(0.5)));
    vec3 col = particle_color.rgb * fade;
    EMISSION = col * 5.0;
    ALPHA = fade * particle_color.a;
}
