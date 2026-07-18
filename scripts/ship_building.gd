extends Node2D

@onready var h_box_container: HBoxContainer = $PanelContainer/HBoxContainer

var parts_array: Array
var selected_part: PackedScene
var selected_instance: Node
var current_slot: int
var part_oob: bool = false

var grid: Array = [[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null]]
var y_range: Array = [192,448]
var x_range: Array = [448,704]

func _ready() -> void:
	parts_array = h_box_container.get_children()
	parts_array[0].z_index = 0
	current_slot = 1
	selected_part = parts_array[0].get_item()
	selected_instance = selected_part.instantiate()
	add_child(selected_instance)

func _process(delta: float) -> void:
	# Make selected part highlighted
	if Input.is_action_just_pressed("slot1") and current_slot != 1:
		selected_instance.queue_free()
		parts_array[0].z_index = 0
		parts_array[1].z_index = -1
		selected_part = parts_array[0].get_item()
		selected_instance = selected_part.instantiate()
		add_child(selected_instance)
		current_slot = 1
	if Input.is_action_just_pressed("slot2") and current_slot != 2:
		selected_instance.queue_free()
		parts_array[0].z_index = -1
		parts_array[1].z_index = 0
		selected_part = parts_array[1].get_item()
		selected_instance = selected_part.instantiate()
		add_child(selected_instance)
		current_slot = 2
	
	# Handle part rotation
	if Input.is_action_just_pressed("e"):
		selected_instance.rotation_degrees += 90
	if Input.is_action_just_pressed("q"):
		selected_instance.rotation_degrees += -90
	
	# Get the grid position so that parts are on a grid.
	var mouse_pos = get_global_mouse_position() + Vector2(32,32)
	var pos = Vector2(mouse_pos.x -fmod(mouse_pos.x, 64),mouse_pos.y -fmod(mouse_pos.y, 64))
	
	# Handle parts positioning and handle when mouse pos is outside of building area.
	if pos.x >= x_range[0] and pos.x <= x_range[1] and pos.y <= y_range[1] and pos.y >= y_range[0] :
		part_oob = false
		selected_instance.visible = true
		selected_instance.position = pos
	else:
		part_oob = true
		selected_instance.visible = false
	
	if Input.is_action_just_pressed("left_click") and !part_oob:
		var relative_pos = pos - Vector2(x_range[0],y_range[0])
		place_part(relative_pos)
	if Input.is_action_just_pressed("right_click") and !part_oob:
		var relative_pos = pos - Vector2(x_range[0],y_range[0])
		remove_part(relative_pos)

func place_part(pos: Vector2):
	var x_grid = pos.x / 64
	var y_grid = pos.y / 64
	if grid[x_grid][y_grid] == null:
		grid[x_grid][y_grid] = [selected_part,x_grid,y_grid,selected_instance]
		new_part()
	else:
		print("Grid is occupied!")

func remove_part(pos: Vector2):
	var x_grid = pos.x / 64
	var y_grid = pos.y / 64
	if grid[x_grid][y_grid] == null:
		print("Grid is already empty!")
	else:
		grid[x_grid][y_grid][3].queue_free()
		grid[x_grid][y_grid] = null

func new_part():
	if current_slot == 1:
		selected_part = parts_array[0].get_item()
		selected_instance = selected_part.instantiate()
	if current_slot == 2:
		selected_part = parts_array[1].get_item()
		selected_instance = selected_part.instantiate()
	add_child(selected_instance)

func _on_build_button_pressed() -> void:
	ShipInfo.update_ship(grid)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
