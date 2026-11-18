shader_type canvas_item;

const vec2 center = vec2(0.5);
uniform float rotation_speed: hint_range(0.0, 1.0) = 0.5;
uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float shade_radius: hint_range(0.0, 1.0) = 0.5;
uniform float noise_step: hint_range(0.0, 1.0) = 0.5;
uniform sampler2D terrain_noise: repeat_enable;
uniform sampler2D base_noise: repeat_enable;
uniform sampler2D cloud_noise: repeat_enable;
uniform vec3 terrain_color: source_color;
uniform vec3 water_color: source_color;
uniform vec3 shore_color: source_color;
uniform vec3 cloud_color: source_color;
uniform vec3 subterrain_color: source_color;
uniform vec3 shade_color: source_color;

uniform int pixel_amount = 40;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// 1. Calculate the pixelated grid UVs right away
	vec2 pixel_uv = floor(UV * float(pixel_amount)) / float(pixel_amount);
	float circle_main = step(distance(pixel_uv, center), radius);
	float inner_circle = smoothstep(0.0,pow(distance(pixel_uv, center),4), shade_radius);
	float shade_ring_alpha = circle_main - inner_circle;
	COLOR.a = circle_main;
	float terain_alpha = step(texture(terrain_noise, pixel_uv + vec2(TIME * rotation_speed,.0)).r, noise_step);
	float subterain_alpha = step(texture(terrain_noise, pixel_uv + vec2(TIME * rotation_speed,.0)).r, noise_step*0.6);
	float beach_alpha = step(texture(terrain_noise, pixel_uv + vec2(TIME * rotation_speed,.0)).r, noise_step*1.2);
	float cloud_alpha = step(texture(cloud_noise, pixel_uv - vec2(TIME * rotation_speed,.0)).r, noise_step*0.8);
	float water_alpha = 1.0 - terain_alpha;
	float shore_alpha = water_alpha - beach_alpha;
	vec3 terain = terain_alpha * terrain_color;
	vec3 subterain = subterain_alpha * subterrain_color;
	vec3 water = water_alpha * water_color;
	vec3 shore = shore_alpha * shore_color;
	vec3 cloud = cloud_alpha * cloud_color;
	vec3 planet = (terain + water) + vec3(TIME);
	vec3 shade = shade_ring_alpha * shade_color;
	COLOR.rgb = terain + subterain + water + shore + cloud - shade;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
