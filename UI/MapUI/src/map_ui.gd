class_name MapUI
extends Control

@export var icons: Dictionary[Quadrant.TYPE, Texture2D]
var map_grid: Array[Array]:
	set(value):
		if not map_grid.is_empty():
			_clear_map()
		map_grid = value
		_init_new_map()

var current_grid_pos: Vector2 = Vector2.INF
var line_array: Array[Line2D]
var icon_dict: Dictionary[Vector2, QuadrantIcon]
var view_port_size: Vector2
var map_h_view_frac: float = 0.8
var map_v_view_frac: float = 0.5
var selected_quadrant_icon: QuadrantIcon
const QUADRANT_ICON = preload("uid://cell8jff8h881")
const PAN_CURSOR = preload("uid://5fti4wk5y0ww")
@onready var quadrant_label: Label = $PanelContainer/HBoxContainer/QuadrantLabel
@onready var button: Button = $PanelContainer/HBoxContainer/Button
@onready var map_elements: Control = $MapElements
@onready var reset_view_button: Button = $ResetViewButton
@onready var panel_container: PanelContainer = $PanelContainer

@export var min_zoom: float = 0.6
@export var max_zoom: float = 2.0
@export var zoom_increment: float = 0.2
var hovering_button: bool = false
var available_quadrants: Array[Quadrant] = []
var lmb_held: bool = false
var mouse_anchor: Vector2
var map_moved: bool = false

signal travel_to_quadrant(Quadrant)

func _ready() -> void:
	view_port_size = get_viewport().get_visible_rect().size
	#generate_map()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		_unselect_quadrant()
		
	if Input.is_action_just_pressed("scroll_up"):
		var new_zoom:= map_elements.scale + Vector2(zoom_increment,zoom_increment)
		if new_zoom > Vector2(max_zoom,max_zoom):
			new_zoom = Vector2(max_zoom,max_zoom)
		if new_zoom != Vector2.ONE:
			_on_map_elements_moved()
		map_elements.scale = new_zoom
	if Input.is_action_just_pressed("scroll_down"):
		var new_zoom:= map_elements.scale - Vector2(zoom_increment,zoom_increment)
		if new_zoom < Vector2(min_zoom,min_zoom):
			new_zoom = Vector2(min_zoom,min_zoom)
		if new_zoom != Vector2.ONE:
			_on_map_elements_moved()
		map_elements.scale = new_zoom

func _input(event:InputEvent) -> void:
	var mouse_event := event
	if mouse_event is InputEventMouseButton:
		var panel_cont_rect: Rect2 = panel_container.get_rect()
		if not panel_cont_rect.has_point(mouse_event.position):
			if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
				lmb_held = true
				mouse_anchor = mouse_event.position - map_elements.position
			elif mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
				lmb_held = false
	if mouse_event is InputEventMouseMotion:
		if lmb_held:
			var map_offset: Vector2 = mouse_event.position - mouse_anchor
			map_elements.position = map_offset

func init_map_ui() -> void:
	_available_quadrants()

func _clear_map() -> void:
	available_quadrants.clear()
	for icon: QuadrantIcon in icon_dict.values():
		icon.queue_free()
	for line in line_array:
		line.queue_free()
	line_array.clear()
	icon_dict.clear()
	current_grid_pos = Vector2.INF

func _init_new_map() -> void:
	var map_size: Vector2 = view_port_size * Vector2(map_h_view_frac, map_v_view_frac)
	var h_sep: float = map_size.x/(len(map_grid) - 1)
	var v_sep: float = map_size.y/(len(map_grid[0]) - 1)
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
					line_array.append(connecting_line)
					connecting_line.add_point(current_quadrant_position)
					var next_grid: Vector2 = next_quadrant.position
					var pos_to_connect: Vector2 = Vector2(left_offset + next_grid.x * h_sep, up_offset + next_grid.y * v_sep)
					connecting_line.add_point(pos_to_connect)
					connecting_line.z_index = -1
					map_elements.add_child(connecting_line)
				icon_dict.set(current_grid, new_quadrant_icon)
				new_quadrant_icon.reachable = false
				map_elements.add_child(new_quadrant_icon)

func _available_quadrants() -> void:
	# Clear previous available quadrants and make them not reachable and not highlighted
	for quadrant: Quadrant in available_quadrants:
		var quadrant_pos: Vector2 = quadrant.position
		var quadrant_icon: QuadrantIcon = icon_dict.get(quadrant_pos)
		quadrant_icon.reachable = false
		quadrant_icon.unhighlighted()
	available_quadrants.clear()
	if current_grid_pos == Vector2.INF:
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

func _on_button_mouse_entered() -> void:
	hovering_button = true

func _on_button_mouse_exited() -> void:
	hovering_button = false

func _on_button_pressed() -> void:
	if selected_quadrant_icon != null:
		print("traveling")
		current_grid_pos = selected_quadrant_icon.quadrant.position
		
		selected_quadrant_icon.highlighted()
		selected_quadrant_icon.reachable = false
		selected_quadrant_icon.unselect_quadrant()
		selected_quadrant_icon = null
		travel_to_quadrant.emit(map_grid[current_grid_pos.x][current_grid_pos.y])

func _on_reset_view_button_pressed() -> void:
	if reset_view_button != null:
		map_elements.scale = Vector2.ONE
		map_elements.position = Vector2.ZERO
		reset_view_button.visible = false


func _on_map_elements_moved() -> void:
	if reset_view_button != null:
		reset_view_button.visible = true
