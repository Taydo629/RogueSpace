shader_type canvas_item;

varying vec2 world_pos;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
const float v_box_top = 248.0;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
}

void fragment() {
	float dist_from_top = (world_pos.y - v_box_top)/v_box_top;
    COLOR = vec4(dist_from_top,dist_from_top,dist_from_top,1.0);
	//COLOR = vec4(SCREEN_UV.y, SCREEN_UV.y, SCREEN_UV.y, 1.0);
	//if (COLOR.r >= 0.5){
		//COLOR = vec4(UV.y,UV.y,UV.y,0.5);
	//}
}

//uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
//
//void fragment() {
    //// Read the rendered output of all children underneath
    //vec4 c = texture(screen_texture, SCREEN_UV);
    //
    //// Apply a continuous gradient across the screen area
    //vec4 gradient = vec4(SCREEN_UV.x, SCREEN_UV.y, 0.0, 1.0);
    //
    //// Multiply or tint the children's colors
    //COLOR = c * gradient;
//}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
