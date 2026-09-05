shader_type canvas_item;

const vec2 center = vec2(0.5);
uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float inner_radius: hint_range(0.0, 1.0) = 0.25;
uniform float highlight_angle;
uniform float highlight_alpha: hint_range(0.0, 1.0) = 0.5;
uniform float highlight_strength: hint_range(0.0, 1.0, 0.1);
uniform vec3 main_color: source_color;
uniform vec3 highlight_color: source_color;
uniform float glow: hint_range(0.0, 1.0);
uniform sampler2D noise: repeat_enable;
uniform float animation_speed: hint_range(0.0, 1.0);

vec2 get_pos_from_angle(float angle) {
	mat2 rot_mat = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle),cos(angle)));
	vec2 up = vec2(0.,0.5);
	return rot_mat * up + center;
}

void vertex(){
	VERTEX += VERTEX * sin(TIME) * 0.05;
}

void fragment() {
	// main shape
	float circle_main = step(distance(UV, center), radius);
	float circle_inner = smoothstep(inner_radius*0.5, 1, distance(UV, center));
	float main_shape = circle_main * circle_inner;
	// highlight shape
	vec2 highlight_center = get_pos_from_angle(highlight_angle);
	float highlight_shape = pow(1. - distance(highlight_center,UV), 2.) * highlight_alpha * main_shape;
	
	// colors
	vec3 color = main_color * main_shape + highlight_shape * highlight_color;
	color *= vec3(glow * 5.);
	
	// texutre
	float texture_alpha = texture(noise, UV + vec2(TIME * animation_speed, 0.0)).r;
	
	COLOR.a = (main_shape + highlight_shape)*texture_alpha;
	COLOR.rgb = color;
}
