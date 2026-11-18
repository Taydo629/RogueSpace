shader_type canvas_item;

instance uniform float flicker_time = 0.0;
const float max_alpha = 0.8;
const float min_alpha = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float blip_alpha = (cos(flicker_time) + 1.0) / 2.0;
	COLOR.a = clamp(blip_alpha, min_alpha, max_alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
