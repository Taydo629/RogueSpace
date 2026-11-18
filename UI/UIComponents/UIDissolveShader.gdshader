shader_type canvas_item;

uniform sampler2D dissolve: repeat_enable;
instance uniform float dissolve_progress: hint_range(0.0, 1.0) = 0.0;
uniform float animation_speed: hint_range(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Disolving
	float disolve_alpha = step(texture(dissolve, UV + vec2(TIME * animation_speed, 0.0)).r, (dissolve_progress));
	COLOR.a = disolve_alpha;
	//COLOR.rgb = mix(COLOR.rgb, texture(dissolve, UV + vec2(TIME * animation_speed, 0.0)).rgb, dissolve_progress);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
