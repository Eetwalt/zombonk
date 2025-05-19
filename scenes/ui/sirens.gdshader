shader_type canvas_item;
// render_mode unshaded; // Optional: Ensures the effect isn't affected by 2D scene lighting.

uniform vec4 red_color: source_color = vec4(1.0, 0.0, 0.0, 0.65);   // Red light color and its base alpha
uniform vec4 blue_color: source_color = vec4(0.0, 0.2, 1.0, 0.65); // Blue light color and its base alpha

uniform float speed : hint_range(0.1, 5.0) = 1.5;
uniform float beam_width : hint_range(0.05, 0.5) = 0.25;
uniform float slant_amount : hint_range(-0.5, 0.5) = 0.15;
uniform float intensity_multiplier : hint_range(0.1, 2.0) = 1.0; // Overall brightness/opacity
uniform float flash_frequency : hint_range(0.0, 10.0) = 0.0;

void fragment() {
    // Effective horizontal coordinate, adjusted by vertical position for a slanted look
    float effective_uv_x = UV.x + (UV.y - 0.5) * slant_amount;

    // --- Red Light ---
    // Calculate the center position of the red light beam
    float red_center_norm = (sin(TIME * speed) + 1.0) * 0.5; // Normalized 0-1 position
    float red_x_pos = red_center_norm * (1.0 + beam_width * 2.0) - beam_width; // Actual screen position

    // Intensity of red light (0 to 1)
    float red_intensity_factor = smoothstep(beam_width, 0.0, abs(effective_uv_x - red_x_pos));

    // --- Blue Light ---
    // Blue light is offset in phase
    float blue_center_norm = (sin(TIME * speed + PI) + 1.0) * 0.5;
    float blue_x_pos = blue_center_norm * (1.0 + beam_width * 2.0) - beam_width;

    // Intensity of blue light (0 to 1)
    float blue_intensity_factor = smoothstep(beam_width, 0.0, abs(effective_uv_x - blue_x_pos));

    // Optional flashing effect
    float flash_mod = 1.0;
    if (flash_frequency > 0.0) {
        // step(0.5, ...) creates a 50% duty cycle for the flash (on half the time, off half the time)
        flash_mod = step(0.5, (sin(TIME * flash_frequency * speed) + 1.0) * 0.5);
    }

    red_intensity_factor *= flash_mod;
    blue_intensity_factor *= flash_mod;

    // Calculate the final RGB color of the siren lights at this pixel.
    // Where lights overlap, their colors will add.
    vec3 final_siren_rgb = red_color.rgb * red_intensity_factor +
                           blue_color.rgb * blue_intensity_factor;

    // Calculate the final alpha for the siren lights at this pixel.
    // This is based on each light's intensity_factor and its defined base alpha (e.g., red_color.a).
    // If lights overlap, their alphas add up (to a max determined by intensity_multiplier and clamp).
    float final_siren_alpha = (red_intensity_factor * red_color.a) +
                              (blue_intensity_factor * blue_color.a);

    // Apply the overall intensity_multiplier to the calculated alpha.
    final_siren_alpha *= intensity_multiplier;

    // Clamp the final alpha to ensure it's between 0.0 (fully transparent) and 1.0 (fully opaque).
    final_siren_alpha = clamp(final_siren_alpha, 0.0, 1.0);

    // Set the shader's output color.
    // The RGB is the combined light color.
    // The Alpha (final_siren_alpha) will be used by the material's blend mode to composite this
    // onto the underlying screen content.
    // If final_siren_alpha is 0, this pixel will be fully transparent (showing the game screen).
    COLOR = vec4(final_siren_rgb, final_siren_alpha);
}
