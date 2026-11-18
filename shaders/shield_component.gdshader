shader_type canvas_item;

const vec2 center = vec2(0.5);
uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float inner_radius: hint_range(0.0, 1.0) = 0.25;
uniform float highlight_alpha: hint_range(0.0, 1.0) = 0.5;
uniform float highlight_strength: hint_range(0.0, 1.0, 0.1);
uniform vec3 main_color: source_color;
uniform vec3 highlight_color: source_color;
uniform vec3 damaged_color: source_color;
instance uniform float damage_frac: hint_range(0.0, 1.0) = 1.0;
uniform float glow: hint_range(0.0, 1.0);
uniform sampler2D noise: repeat_enable;
uniform sampler2D dissolve: repeat_enable;
instance uniform float dissolve_progress: hint_range(0.0, 1.0) = 0.0;
uniform float animation_speed: hint_range(0.0, 1.0);
uniform float highlight_speed: hint_range(0.0, 1.0) = 2.0;

vec2 get_pos_from_angle() {
	float time = TIME * 10.0 * highlight_speed;
	vec2 dir = vec2(cos(-time), sin(-time));
	return center + dir * radius;
}

void vertex(){
	VERTEX += VERTEX * sin(TIME * (10. * (1.0 - damage_frac))) * 0.05;
}

void fragment() {
	// main shape
	float circle_main = step(distance(UV, center), radius);
	float circle_inner = smoothstep(inner_radius*0.5, 1, distance(UV, center));
	float main_shape = circle_main * circle_inner;

	// highlight shape
	vec2 highlight_center = get_pos_from_angle();
	float highlight_shape = pow(1. - distance(highlight_center,UV), 2.) * highlight_alpha * main_shape;
	
	// colors
	vec3 main_color_with_damage = mix(damaged_color * main_shape,main_color * main_shape, damage_frac);
	vec3 color = main_color_with_damage + highlight_shape * highlight_color;
	color *= vec3(glow * 5.);
	
	// Texture sampling
	float texture_alpha = texture(noise, UV + vec2(TIME * animation_speed, 0.0)).r;
	
	// Disolving
	float disolve_alpha = step(texture(dissolve, UV + vec2(TIME * animation_speed, 0.0)).r, (1.0 - dissolve_progress));
	
	COLOR.a = (main_shape + highlight_shape)*texture_alpha * disolve_alpha;
	COLOR.rgb = color;
}
