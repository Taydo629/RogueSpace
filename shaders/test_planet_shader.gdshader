shader_type canvas_item;

const vec2 center = vec2(0.5);
uniform float rotation_speed: hint_range(0.0, 1.0) = 0.5;
uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float noise_step: hint_range(0.0, 1.0) = 0.5;
uniform sampler2D terrain_noise: repeat_enable;
uniform sampler2D base_noise: repeat_enable;
uniform vec3 terrain_color: source_color;
uniform vec3 water_color: source_color;

uniform int pixel_amount = 40;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// 1. Calculate the pixelated grid UVs right away
	vec2 pixel_uv = floor(UV * float(pixel_amount)) / float(pixel_amount);
	float circle_main = step(distance(pixel_uv, center), radius);
	COLOR.a = circle_main;
	float terain_alpha = step(texture(terrain_noise, pixel_uv + vec2(TIME * rotation_speed)).r, noise_step);
	float water_alpha = 1.0 - terain_alpha;
	vec3 terain = terain_alpha * terrain_color;
	vec3 water = water_alpha * water_color;
	vec3 planet = (terain + water) + vec3(TIME);
	COLOR.rgb = terain + water;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
