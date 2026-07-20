extends HBoxContainer

var selected_part: Part
var parts_array: Array
var current_slot: int
var selected_instance: Node
@onready var ship_building: Node2D = $"../.."

func init_hotbar() -> void:
	parts_array = get_children()
	parts_array[0].z_index = 0
	current_slot = 0
	selected_part = parts_array[0].get_part()
	selected_instance = selected_part.scene.instantiate()
	ship_building.add_child(selected_instance)

func _process(delta: float) -> void:
	var scroll_delta = 0
	if Input.is_action_just_pressed("scroll_up"):
		scroll_delta = 1
	if Input.is_action_just_pressed("scroll_down"):
		scroll_delta = -1
	if scroll_delta != 0:
		change_select(scroll_delta)

func change_select(delta: int) -> void:
	var last_slot: int = len(parts_array)-1
	var new_slot: int = current_slot + delta
	if last_slot < new_slot:
		new_slot = 0
	if 0 > new_slot:
		new_slot = last_slot
	selected_instance.queue_free()
	for i in range(len(parts_array)):
		if i == new_slot:
			parts_array[i].z_index = 0
		else:
			parts_array[i].z_index = -1
	selected_part = parts_array[new_slot].get_part()
	selected_instance = selected_part.scene.instantiate()
	ship_building.add_child(selected_instance)
	current_slot = new_slot

func new_part():
	selected_part = parts_array[current_slot].get_part()
	selected_instance = selected_part.scene.instantiate()
	ship_building.add_child(selected_instance)
