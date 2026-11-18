shader_type canvas_item;

instance uniform bool highlighted = false;
instance uniform bool reachable = true;
instance uniform bool selected = false;
instance uniform float line_thickness: hint_range(0.0 , 1.0) = 1.0;
uniform vec4 line_color : source_color = vec4(1, 1, 1, 1);
uniform vec4 disabled_color : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform float pulse_strength : hint_range(0., 1.) = 0.5;
uniform float pulse_speed : hint_range(0., 1.) = 0.5;
const float max_line_thickness = 4.;

void vertex() {
	if (highlighted) {
		VERTEX += VERTEX * sin(TIME * (10. * pulse_speed)) * pulse_strength;
	}
}

void fragment() {
	if (selected) {
		vec4 color = texture(TEXTURE, UV);
		vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
		float outline = color.a;
		outline += texture(TEXTURE, UV + vec2(size.x,0)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x,0)).a;
		outline += texture(TEXTURE, UV + vec2(0,size.y)).a;
		outline += texture(TEXTURE, UV + vec2(0,-size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x,size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x,size.y)).a;
		outline += texture(TEXTURE, UV + vec2(size.x,-size.y)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x,-size.y)).a;
		outline = min(outline, 1.0);
		COLOR = mix(color, line_color, outline - color.a);
	}
	if (reachable == false) {
		COLOR *= disabled_color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
