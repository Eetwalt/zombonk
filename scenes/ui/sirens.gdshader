shader_type canvas_item;

uniform vec4 red_color: source_color = vec4(1.0, 0.0, 0.0, 0.65);   // Red flash color
uniform vec4 blue_color: source_color = vec4(0.0, 0.2, 1.0, 0.65);  // Blue flash color

uniform float speed : hint_range(0.1, 5.0) = 1.5;
uniform float intensity_multiplier : hint_range(0.1, 2.0) = 1.0;
uniform float flash_frequency : hint_range(0.0, 10.0) = 1.0;

// Define the width of the colored sections (30% of the screen)
const float color_section_width = 0.3;

// Calculate boundaries based on the defined width
const float left_section_end_uv = color_section_width;       // e.g., 0.3 for 30%
const float right_section_start_uv = 1.0 - color_section_width; // e.g., 0.7 for 30%

void fragment() {
    float red_flash_mod = 1.0;
    float blue_flash_mod = 1.0;

    if (flash_frequency > 0.0) {
        float angular_freq = flash_frequency * speed * 2.0 * PI;
        float flash_signal = (sin(TIME * angular_freq) + 1.0) * 0.5; // Ranges 0.0 to 1.0

        red_flash_mod = step(0.5, flash_signal); // Red on first half of cycle
        blue_flash_mod = 1.0 - red_flash_mod;   // Blue on second half
    } else {
        // If frequency is 0, both sides are constantly "on" (respecting their gradient)
        red_flash_mod = 1.0;
        blue_flash_mod = 1.0;
        // To make them off if frequency is 0, set these to 0.0 instead.
    }

    vec4 color_out = vec4(0.0); // Initialize to transparent black
    float gradient_alpha_mod;

    if (UV.x < left_section_end_uv) {
        // Left section: Red, gradient from left (full alpha) to its right edge (zero alpha)
        // UV.x ranges from 0.0 to left_section_end_uv (e.g., 0.3)
        gradient_alpha_mod = 1.0 - (UV.x / left_section_end_uv);
        gradient_alpha_mod = clamp(gradient_alpha_mod, 0.0, 1.0);

        color_out.rgb = red_color.rgb;
        color_out.a = red_color.a * gradient_alpha_mod * red_flash_mod * intensity_multiplier;
    } else if (UV.x >= right_section_start_uv) {
        // Right section: Blue, gradient from its left edge (zero alpha) to right (full alpha)
        // UV.x ranges from right_section_start_uv (e.g., 0.7) to 1.0
        // The width of this section is (1.0 - right_section_start_uv), which is color_section_width
        gradient_alpha_mod = (UV.x - right_section_start_uv) / (1.0 - right_section_start_uv);
        // which is equivalent to: (UV.x - right_section_start_uv) / color_section_width;
        gradient_alpha_mod = clamp(gradient_alpha_mod, 0.0, 1.0);

        color_out.rgb = blue_color.rgb;
        color_out.a = blue_color.a * gradient_alpha_mod * blue_flash_mod * intensity_multiplier;
    } else {
        // Middle section: This will remain transparent as color_out was initialized to vec4(0.0)
        // No action needed here for transparency.
    }

    color_out.a = clamp(color_out.a, 0.0, 1.0); // Final clamp for safety
    COLOR = color_out;
}