shader_type canvas_item;

const vec2 center = vec2(0.5);

uniform vec3 radar_color: source_color;
uniform float radar_opacity: hint_range(0.5,1.0) = 0.8;
uniform float radius: hint_range(0.0, 1.0) = 0.5;
uniform float default_ring_thickness = 0.1;
uniform float ring_thickness_modifer: hint_range(0.0, 1.0) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float ring_thickness = default_ring_thickness * ring_thickness_modifer;
	float ring_outer = step(distance(UV, center), 0.500) - step(distance(UV, center), 0.5 - ring_thickness);
	float ring_middle = step(distance(UV, center), 0.333) - step(distance(UV, center), 0.333 - ring_thickness);
	float ring_inner = step(distance(UV, center), 0.167) - step(distance(UV, center), 0.167 - ring_thickness);
	float rings = ring_outer + ring_middle + ring_inner;
	COLOR.rgb = radar_color;
	COLOR.a = rings * radar_opacity;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
