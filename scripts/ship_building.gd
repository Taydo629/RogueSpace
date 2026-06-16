extends Node2D

@onready var h_box_container: HBoxContainer = $PanelContainer/HBoxContainer

var parts_array: Array
var selected_part: Node
var current_slot: int

func _ready() -> void:
	parts_array = h_box_container.get_children()
	parts_array[0].z_index = 0
	current_slot = 1
	selected_part = parts_array[0].get_item().instantiate()
	add_child(selected_part)

func _process(delta: float) -> void:
	# Make selected part highlighted
	if Input.is_action_just_pressed("slot1") and current_slot != 1:
		selected_part.queue_free()
		parts_array[0].z_index = 0
		parts_array[1].z_index = -1
		selected_part = parts_array[0].get_item().instantiate()
		add_child(selected_part)
		current_slot = 1
	if Input.is_action_just_pressed("slot2") and current_slot != 2:
		selected_part.queue_free()
		parts_array[0].z_index = -1
		parts_array[1].z_index = 0
		selected_part = parts_array[1].get_item().instantiate()
		add_child(selected_part)
		current_slot = 2
	
	# Handle part rotation
	if Input.is_action_just_pressed("e"):
		selected_part.rotation_degrees += 90
	if Input.is_action_just_pressed("q"):
		selected_part.rotation_degrees += -90
	
	# Get the grid position so that parts are on a grid.
	var mouse_pos = get_global_mouse_position() + Vector2(32,32)
	var pos = Vector2(mouse_pos.x -fmod(mouse_pos.x, 64),mouse_pos.y -fmod(mouse_pos.y, 64))
	
	selected_part.position = pos
	
	
