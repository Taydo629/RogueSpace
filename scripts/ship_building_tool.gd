extends CanvasLayer

@onready var item_list: ItemList = $ShipBuildingUI/FoldableContainer/Control/ItemList
@onready var item_info_label: Label = $ShipBuildingUI/FoldableContainer/Control/ItemInfoLabel
@onready var part_container: Node2D = $PartContainer

var loaded_parts: Array[Part] = []
var instantiated_item: RigidBody2D
var instantiated_part: Part
var selected_item_idx: int
var current_mouse_pos: Vector2 = Vector2.ZERO
var y_range: Array = [128,512]
var x_range: Array = [384,768]
var building_dict: Dictionary = {}

const SAVE_DIR: String = "res://data/ShipGraphs/"

signal build_complete

func _ready() -> void:
	get_tree().paused = true
	load_all_parts_from_folder("res://data/Parts/")
	update_partlist()

func load_all_parts_from_folder(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore subdirectories and non-resource files
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = path + "/" + file_name
				var part_resource = load(full_path) as Part
				
				if part_resource:
					loaded_parts.append(part_resource)
					
			file_name = dir.get_next()
		dir.list_dir_end()
		
	print("Total loaded parts: ", loaded_parts.size())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and instantiated_item != null:
		move_part(event.position)
	elif event is InputEventKey and event.pressed == true:
		if event.as_text_keycode() == "E":
			rotate_part(1)
		elif event.as_text_keycode() == "Q":
			rotate_part(-1)
		elif event.as_text_keycode() == "M":
			mirror_part()
	elif event is InputEventMouseButton and event.pressed == true:
		if event.button_index == 1:
			place_part()
		elif event.button_index == 2:
			remove_part()

func place_part() -> void:
	if current_mouse_pos != Vector2.ZERO:
		var grid_pos: Vector2 = (Vector2(current_mouse_pos) - Vector2(x_range[0],y_range[0]) - Vector2(32,32))/64
		if str(grid_pos) not in building_dict.keys():
			var node_dict: Dictionary = {
				"part": instantiated_part,
				"instance": instantiated_item,
				"grid_pos": grid_pos,
				"rotation": instantiated_item.rotation,
				"scale": instantiated_item.scale
			}
			building_dict.set(str(grid_pos),node_dict)
			if check_part_owned(instantiated_part):
				instantiate_part(instantiated_part)
				item_info_label.text = str("Inf in inventory")
		else:
			print("A part is already placed here!")
	else:
		print("Mouse out of bounds!")

func remove_part() -> void:
	if current_mouse_pos != Vector2.ZERO:
		var grid_pos: Vector2 = (Vector2(current_mouse_pos) - Vector2(x_range[0],y_range[0]) - Vector2(32,32))/64
		if str(grid_pos) in building_dict.keys():
			var node = building_dict.get(str(grid_pos))
			node.instance.queue_free()
			building_dict.erase(str(grid_pos))
			print("Part removed")
		else:
			print("No part to remove!")
	else:
		print("Mouse out of bounds!")

func move_part(position: Vector2) -> void:
	## Get the grid position so that parts are on a grid.
	var mouse_pos = position
	var pos = Vector2(mouse_pos.x -fmod(mouse_pos.x, 64),mouse_pos.y -fmod(mouse_pos.y, 64)) + Vector2(32,32)
	# Handle parts positioning and handle when mouse pos is outside of building area.
	if pos.x >= x_range[0] and pos.x <= x_range[1] and pos.y <= y_range[1] and pos.y >= y_range[0] :
		instantiated_item.visible = true
		instantiated_item.position = pos
		current_mouse_pos = pos
	else:
		instantiated_item.visible = false
		current_mouse_pos = Vector2.ZERO
	instantiated_item.position = pos

func rotate_part(direction: int) -> void:
	instantiated_item.rotate(0.5 * PI * direction)

func mirror_part() -> void:
	instantiated_item.scale *= Vector2(-1,1)

func instantiate_part(part: Part) -> void:
	instantiated_part = part
	instantiated_item = part.scene.instantiate()
	instantiated_item.visible = false
	part_container.add_child(instantiated_item)

func kill_selected_part() -> void:
	instantiated_item.queue_free()
	instantiated_part = null
	instantiated_item = null

func update_partlist() -> void:
	var already_added_part: Array[Part]
	for part in loaded_parts:
		if part not in already_added_part:
			item_list.add_item(part.name, part.image)
			already_added_part.append(part)

func get_selected_part_name() -> String:
	return item_list.get_item_text(selected_item_idx)

func check_part_owned(part: Part) -> bool:
	if part in Inventory.inventory:
		return true
	else:
		return false

func update_partinfo(idx: int) -> Part:
	var number_of_selected_part:int = 0
	var selected_part_name: String = item_list.get_item_text(idx)
	var selected_part: Part
	for part in loaded_parts:
		if part.name == selected_part_name:
			number_of_selected_part += 1
			if selected_part == null:
				selected_part = part
	item_info_label.text = str("Inf in inventory")
	return selected_part


## Function to assign parts neighbors.
##
## If no neighbors are present or core part is missing will return false.
## Otherwise will return true.
func assign_neighbors() -> bool:
	var core_present: bool = false
	for current_node in building_dict.values():
		if current_node.part.name == "core":
			core_present = true
		var possible_direction_array: Array[Vector2] = [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]
		var possible_neighbor_pos: Array = possible_direction_array.map(func(i): return i + current_node.grid_pos)
		var neighbor_array: Array[String] = []
		for neighbor_node in building_dict.values():
			if neighbor_node.grid_pos in possible_neighbor_pos:
				neighbor_array.append(str(neighbor_node.grid_pos))
		if neighbor_array.is_empty():
			print("Part has no neighbors!")
			return false
		current_node.set("neighbors", neighbor_array)
	if not core_present:
		print("Ship has no core!")
		return false
	return true

func _on_item_list_item_selected(index: int) -> void:
	selected_item_idx = index
	var selected_part = update_partinfo(index)
	
	if selected_part != null:
		instantiate_part(selected_part)
	else:
		kill_selected_part()
		if check_part_owned(selected_part):
			instantiate_part(selected_part)

func _on_build_button_pressed() -> void:
	if building_dict.is_empty():
		print("No parts are placed!")
		return
	if assign_neighbors():
		save_dict_var(building_dict, SAVE_DIR)
		get_tree().quit()

func save_dict_var(dict: Dictionary, dir: String) -> void:
	var path: String = str(dir, "new_graph.txt")
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		# Encodes the dictionary directly to a GDScript text format
		file.store_string(var_to_str(dict))
		file.close()
