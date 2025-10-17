// Tells Godot this is a spatial shader (for 3D)
shader_type spatial;

// Set the blend mode to additive to make it glow brightly over other objects
render_mode blend_add, unshaded;

// Uniforms are variables you can control from the Inspector or GDScript
uniform vec4 lightning_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform float jaggedness : hint_range(0.0, 1.0) = 0.3;
uniform float speed : hint_range(0.0, 10.0) = 5.0;

void vertex() {
    // We only want to displace the mesh side-to-side, not up and down.
    // The displacement is zero at the start (UV.y=0) and end (UV.y=1) of the mesh.
    // This keeps the lightning connected to the hand and the target.
    float displacement_multiplier = sin(UV.y * PI);

    // Generate jagged, time-varying noise using sine waves
    // Displace on the X axis
    VERTEX.x += sin(VERTEX.y * 10.0 + TIME * speed) * jaggedness * displacement_multiplier;
    // Displace on the Z axis
    VERTEX.z += sin(VERTEX.y * 15.0 + TIME * speed * 1.5) * jaggedness * displacement_multiplier;
}

void fragment() {
    // Set the base color and alpha
    ALBEDO = lightning_color.rgb;
    // Set the emission to make the lightning glow
    EMISSION = lightning_color.rgb * 2.0;
}