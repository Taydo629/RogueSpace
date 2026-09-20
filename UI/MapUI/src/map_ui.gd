class_name MapUI
extends Control

# Testing with script inside level_gen_component
@export var sector_width: int = 5
@export var layers: int = 8
@export var num_of_paths: int = 3
@export var icons: Dictionary[Quadrant.TYPE, Texture2D]
var map_grid: Array[Array]
var current_grid_pos: Vector2

var icon_dict: Dictionary[Vector2, QuadrantIcon]
var view_port_size: Vector2
var map_h_view_frac: float = 0.8
var map_v_view_frac: float = 0.5
var selected_quadrant_icon: QuadrantIcon
const QUADRANT_ICON = preload("uid://cell8jff8h881")
@onready var quadrant_label: Label = $PanelContainer/HBoxContainer/QuadrantLabel
@onready var button: Button = $PanelContainer/HBoxContainer/Button
var hovering_button: bool = false

func _ready() -> void:
	view_port_size = get_viewport().get_visible_rect().size
	generate_map()
	_init_map_ui()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		_unselect_quadrant()

func _init_map_ui() -> void:
	var map_size: Vector2 = view_port_size * Vector2(map_h_view_frac, map_v_view_frac)
	var h_sep: float = map_size.x/(layers - 1)
	var v_sep: float = map_size.y/(sector_width - 1)
	var left_offset: float = (view_port_size.x - map_size.x)/1.5
	var up_offset: float = (view_port_size.y - map_size.y)/2
	for layer in map_grid:
		for quadrant: Quadrant in layer:
			if quadrant.type == Quadrant.TYPE.EMPTY:
				pass
			else:
				var current_grid: Vector2 = quadrant.position
				var new_quadrant_icon: QuadrantIcon = QUADRANT_ICON.instantiate()
				var current_quadrant_position = Vector2(left_offset + current_grid.x * h_sep, up_offset + current_grid.y * v_sep)
				new_quadrant_icon.quadrant = quadrant
				new_quadrant_icon.icon_texture = icons.get(quadrant.type)
				new_quadrant_icon.set_position(current_quadrant_position)
				new_quadrant_icon.selected.connect(_select_quadrant)
				for next_quadrant: Quadrant in quadrant.next_quadrant:
					# Create Line
					var connecting_line: Line2D = Line2D.new()
					connecting_line.add_point(current_quadrant_position)
					var next_grid: Vector2 = next_quadrant.position
					var pos_to_connect: Vector2 = Vector2(left_offset + next_grid.x * h_sep, up_offset + next_grid.y * v_sep)
					connecting_line.add_point(pos_to_connect)
					connecting_line.z_index = -1
					add_child(connecting_line)
				icon_dict.set(current_grid, new_quadrant_icon)
				new_quadrant_icon.reachable = false
				add_child(new_quadrant_icon)
	
	_available_quadrants()

func _available_quadrants() -> void:
	var available_quadrants: Array[Quadrant] = []
	if current_grid_pos == Vector2.ZERO:
		for candidate_quadrant: Quadrant in map_grid[0]:
			if candidate_quadrant.type != Quadrant.TYPE.EMPTY:
				available_quadrants.append(candidate_quadrant)
	else:
		var current_quadrant: Quadrant = map_grid[current_grid_pos.x][current_grid_pos.y]
		for next_quadrants: Quadrant in current_quadrant.next_quadrant:
			available_quadrants.append(next_quadrants)
	for quadrant: Quadrant in available_quadrants:
		var grid_pos: Vector2 = quadrant.position
		var quadrant_icon: QuadrantIcon = icon_dict.get(grid_pos)
		print(quadrant_icon)
		quadrant_icon.highlighted()
		quadrant_icon.reachable = true

func _select_quadrant(selected_quadrant: QuadrantIcon) -> void:
	button.disabled = false
	selected_quadrant_icon = selected_quadrant
	var label_text: String = "Selected Quadrant: a%s-b%s"  % [int(selected_quadrant.quadrant.position.x)+1, int(selected_quadrant.quadrant.position.y)+1]
	quadrant_label.text = label_text

func _unselect_quadrant() -> void:
	if selected_quadrant_icon != null:
		if hovering_button:
			return
		if selected_quadrant_icon.unselect_quadrant():
			selected_quadrant_icon = null
			button.disabled = true
			var label_text: String = "Select a quadrant to continue!"
			quadrant_label.text = label_text
		else:
			return
	else:
		return

func generate_map() -> void:
	# Create and initial grid of quadrants
	var initial_map_grid: Array[Array] = []
	for i in layers:
		var layer_array: Array[Quadrant]
		for j in sector_width:
			var new_quadrant: Quadrant = Quadrant.new()
			new_quadrant.position = Vector2(i,j)
			new_quadrant.next_quadrant = []
			layer_array.append(new_quadrant)
		initial_map_grid.append(layer_array)
	
	# Randomise quadrant type
	for layer in initial_map_grid:
		for quadrant: Quadrant in layer:
			quadrant.set_random_type()
	
	# Add in the boss quadrant
	var boss_quadrant: Quadrant = Quadrant.new()
	@warning_ignore("integer_division")
	var mid_point_row: int = sector_width/2
	print(mid_point_row)
	var boss_pos: Vector2 = Vector2(layers - 1, mid_point_row)
	boss_quadrant.position = Vector2(layers - 1,mid_point_row)
	boss_quadrant.type = Quadrant.TYPE.BOSS
	initial_map_grid[layers - 1][mid_point_row] = boss_quadrant
	
	# Select some rows to start from
	var starting_rows: Array[int] = []
	for path in num_of_paths:
		starting_rows.append(randi_range(0, sector_width-1))
	
	# Create paths
	for starting_point in starting_rows:
		var current_pos:= Vector2(0,starting_point)
		for layer in layers-1:
			var current_quadrant: Quadrant = initial_map_grid[layer][current_pos.y]
			var possible_rows: Array[int] = []
			if current_pos.y > 0:
				possible_rows.append(current_pos.y - 1)
			if current_pos.y < sector_width - 1:
				possible_rows.append(current_pos.y + 1)
			# Check for crossing paths
			for candidate_row in possible_rows:
				var adjacent_quadrant: Quadrant = initial_map_grid[layer][candidate_row]
				if len(adjacent_quadrant.next_quadrant) != 0:
					for next_quadrant in adjacent_quadrant.next_quadrant:
						if next_quadrant.position.y == current_pos.y:
							possible_rows.erase(adjacent_quadrant.position.y)
			possible_rows.append(current_pos.y)
			# Last layer before boss
			if layer == layers -2:
				# Connect second to last layer to boss quadrant
				if initial_map_grid[boss_pos.x][boss_pos.y] not in current_quadrant.next_quadrant:
					current_quadrant.next_quadrant.append(initial_map_grid[boss_pos.x][boss_pos.y])
			else:
				var next_row: int = possible_rows.pick_random()
				if initial_map_grid[layer + 1][next_row] not in current_quadrant.next_quadrant:
					current_quadrant.next_quadrant.append(initial_map_grid[layer + 1][next_row])
				current_pos = Vector2(layer + 1, next_row)
	
	# Create a layer which has combat in the middle
	# This also ensures that at minimum 1 combat exists within each path
	@warning_ignore("integer_division")
	var quater_of_layers: int = layers/4
	@warning_ignore("integer_division")
	var mid_point_layer: int = layers/2
	var combat_layer: int = randi_range(mid_point_layer-quater_of_layers, mid_point_layer+quater_of_layers)
	for j in sector_width:
		var quadrant: Quadrant = initial_map_grid[combat_layer][j]
		quadrant.type = Quadrant.TYPE.COMBAT
	
	# Remove quadrants which have no connections
	for i in layers:
		var quadrant_to_remove: Array[Quadrant] = []
		for j in sector_width:
			var quadrant: Quadrant = initial_map_grid[i][j]
			if len(quadrant.next_quadrant) == 0 and quadrant.type != Quadrant.TYPE.BOSS:
				quadrant_to_remove.append(quadrant)
		for quadrant in quadrant_to_remove:
			quadrant.type = Quadrant.TYPE.EMPTY
	
	# Debug print
	print(initial_map_grid)
	for layer in initial_map_grid:
		for row:Quadrant in layer:
			if row.type != Quadrant.TYPE.EMPTY:
				if len(row.next_quadrant) != 0 or row.type == Quadrant.TYPE.BOSS:
					var next_pos: Array[Vector2]
					for connection: Quadrant in row.next_quadrant:
						next_pos.append(connection.position)
					print("%s at %s with connections to %s" % [row, row.position,next_pos])
	map_grid = initial_map_grid


func _on_button_mouse_entered() -> void:
	hovering_button = true


func _on_button_mouse_exited() -> void:
	hovering_button = false
