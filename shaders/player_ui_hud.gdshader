shader_type canvas_item;

varying vec2 world_pos;
uniform vec2 canvas_center;
uniform float circle_size : hint_range(1., 10.) = 5;
uniform float ring_width : hint_range(0.0, 1.0) = 0.5;
uniform vec2 player_pos;
uniform float enemy_ang[10];
uniform int enemy_count;
uniform float indicator_a : hint_range(0., 1.) = 0.5;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
}

void fragment() {
	float circle = distance(world_pos, canvas_center)/100.;
	float inner_circle =  distance(world_pos, canvas_center)/((1. - ring_width) * 100.);
	float ring = step(circle, circle_size) - step(inner_circle, circle_size);
	float angle_mask = 0.;
	//for (int i = 0; i < enemy_count; i++) {
		//vec2 v1 = normalize(world_pos - canvas_center);
		//vec2 v2 = normalize(enemy_pos[i] - canvas_center);
		//angle_mask += step(acos(dot(v1,v2)), 0.1) * indicator_a;
	//}
	vec2 v1 = normalize(world_pos - canvas_center);
	vec2 v2 = normalize(vec2(0.,100.) - canvas_center);
	angle_mask += step(acos(dot(v1,v2)), 0.1) * indicator_a;
	//COLOR.a = ring;
	COLOR.a = angle_mask * ring;
}
