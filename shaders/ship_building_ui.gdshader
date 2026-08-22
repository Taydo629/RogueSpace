shader_type canvas_item;

varying vec2 world_pos;
uniform float grid_size : hint_range(1., 256.);
uniform float line_width : hint_range(0., 1.);
uniform float line_default_a : hint_range(0., 1.) = 0.5;
uniform float circle_size : hint_range(1., 500.) = 250;
uniform vec2 mouse_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
}

void fragment() {
	// Functional
	float x_line = abs(fract(world_pos.x/grid_size)-0.5);
	float y_line = abs(fract(world_pos.y/grid_size)-0.5);
	float grid_lines = (step(x_line,line_width/100./TEXTURE_PIXEL_SIZE.x) + step(y_line,line_width/100./TEXTURE_PIXEL_SIZE.y)) * line_default_a;
	float mouse_pos_circle = step(distance(world_pos, mouse_pos), circle_size);
	COLOR.a = grid_lines * mouse_pos_circle + grid_lines;
	//float mouse_pos_circle = step(distance(world_pos, mouse_pos)/2., circle_size);
	//COLOR.a = mouse_pos_circle;
}
