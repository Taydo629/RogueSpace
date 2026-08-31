class_name BuildUI extends Control

@onready var item_list: ItemList = $FoldableContainer/Control/ItemList
@onready var foldable_container: FoldableContainer = $FoldableContainer
@onready var item_info_label: Label = $FoldableContainer/Control/ItemInfoLabel
@onready var texture_rect: ColorRect = $TextureRect
@onready var build_area: Polygon2D = $BuildArea
@onready var build_repair_toggle: BuildRepairToggle = $BuildRepairToggle
@onready var repair_popup: RepairPopup = $RepairPopup
@onready var credit_ui: Label = $CreditUI

enum MODES{BUILDING, REPAIR}

var player: Player
var instantiated_item: RigidBody2D
var instantiated_part: Part
var selected_item_idx: int
var current_mouse_pos: Vector2 = Vector2.ZERO
var grid_dim: float = 5
var grid_size: float = 64
var y_range: Array
var x_range: Array
var building_dict: Dictionary = {}
var current_mode: MODES
var selected_key_for_repair: String

signal build_complete

func _ready() -> void:
	repair_popup.parent = self
	build_repair_toggle.build_mode.connect(enter_build_mode)
	build_repair_toggle.repair_mode.connect(enter_repair_mode)
	Inventory.credit_changed.connect(update_credit)

func init_ui() -> void:
	texture_rect.material.set_shader_parameter("grid_size", grid_size)
	var viewport_size: Vector2 = get_viewport_rect().size
	var grid_centre_x: float = int((viewport_size.x/grid_size)/2) * grid_size
	var grid_centre_y: float = int((viewport_size.y/grid_size)/2) * grid_size
	build_area.scale = Vector2(grid_dim,grid_dim)
	build_area.global_position = Vector2(grid_centre_x,grid_centre_y)
	var grid_edge_dist_from_centre: float = grid_dim * grid_size / 2.0
	y_range = [grid_centre_y - grid_edge_dist_from_centre, grid_centre_y + grid_edge_dist_from_centre]
	x_range = [grid_centre_x - grid_edge_dist_from_centre, grid_centre_x + grid_edge_dist_from_centre]
	build_repair_toggle.init()

func start_build() -> void:
	building_dict.clear()
	for value in player.part_component.ship_graph.values():
		var part_instance: BasePart = value.instance
		part_instance.detached()
		part_instance.reparent(self)
		part_instance.global_position = (value.grid_pos * 64 + Vector2(x_range[0], y_range[0]) - Vector2(grid_size,grid_size)/2.) + Vector2(grid_size,grid_size)
		part_instance.scale = value.scale
		part_instance.rotation = value.rotation
	building_dict = player.part_component.ship_graph.duplicate(true)
	update_partlist()
	enter_build_mode()

func enter_build_mode() -> void:
	credit_ui.visible = false
	current_mode = MODES.BUILDING
	foldable_container.visible = true

func enter_repair_mode() -> void:
	credit_ui.visible = true
	update_credit()
	current_mode = MODES.REPAIR
	item_list.deselect_all()
	foldable_container.visible = false
	kill_selected_part()

func update_credit() -> void:
	var credit_str: String = "%s CR"
	print(credit_str)
	print(credit_str % Inventory.wallet)
	credit_ui.text = credit_str % Inventory.wallet

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		texture_rect.material.set_shader_parameter("mouse_pos", event.position)
		if instantiated_item != null:
			move_part(event.position)
		elif current_mode == MODES.REPAIR and not repair_popup.visible:
			select_part_to_repair(event.position)
	elif event is InputEventKey and event.pressed == true:
		if event.as_text_keycode() == "E":
			rotate_part(1)
		elif event.as_text_keycode() == "Q":
			rotate_part(-1)
		elif event.as_text_keycode() == "M":
			mirror_part()
	elif event is InputEventMouseButton and event.pressed == true:
		if event.button_index == 1:
			if current_mode == MODES.REPAIR and not repair_popup.visible:
				repair_part()
			if current_mode == MODES.BUILDING:
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
				"scale": instantiated_item.scale,
				"health": instantiated_item.health
			}
			building_dict.set(str(grid_pos),node_dict)
			if check_part_owned(instantiated_part):
				instantiate_part(instantiated_part)
				Inventory.remove_item(instantiated_part)
				item_info_label.text = str(Inventory.inventory.count(instantiated_part), " in inventory")
		else:
			print("A part is already placed here!")
	else:
		print("Mouse out of bounds!")

func repair_part() -> void:
	if selected_key_for_repair != "":
		var node_to_repair:Dictionary = building_dict.get(selected_key_for_repair)
		repair_popup.init_slider(node_to_repair.instance, node_to_repair.part)
		repair_popup.position = node_to_repair.instance.position
		repair_popup.visible = true

func remove_part() -> void:
	if current_mouse_pos != Vector2.ZERO:
		var grid_pos: Vector2 = (Vector2(current_mouse_pos) - Vector2(x_range[0],y_range[0]) - Vector2(32,32))/64
		if str(grid_pos) in building_dict.keys():
			var node = building_dict.get(str(grid_pos))
			node.instance.queue_free()
			Inventory.add_item(node.part)
			if node.part.name == get_selected_part_name():
				item_info_label.text = str(Inventory.inventory.count(node.part), " in inventory")
			building_dict.erase(str(grid_pos))
			update_partlist()
			print("Part removed")
		else:
			print("No part to remove!")
	else:
		print("Mouse out of bounds!")

func move_part(_position: Vector2) -> void:
	## Get the grid position so that parts are on a grid.
	var mouse_pos = _position
	# Get mouse pos and convert into grid coordinates
	# Grid starts at 0 with half a grid hence adding half a grid to the mouse pos to offset.
	# By subtracting the modulus we get snapping to the grid.
	var pos = Vector2(mouse_pos.x + grid_size/2 - fmod(mouse_pos.x + grid_size/2, grid_size),
						mouse_pos.y + grid_size/2 - fmod(mouse_pos.y + grid_size/2, grid_size))
	# Handle parts positioning and handle when mouse pos is outside of building area.
	if pos.x >= x_range[0] and pos.x <= x_range[1] and pos.y <= y_range[1] and pos.y >= y_range[0] :
		instantiated_item.visible = true
		instantiated_item.position = pos
		current_mouse_pos = pos
	else:
		instantiated_item.visible = false
		current_mouse_pos = Vector2.ZERO
	instantiated_item.position = pos

func select_part_to_repair(_position: Vector2) -> void:
	var mouse_pos = _position
	# Get mouse pos and convert into grid coordinates
	# Grid starts at 0 with half a grid hence adding half a grid to the mouse pos to offset.
	# By subtracting the modulus we get snapping to the grid.
	var pos = Vector2(mouse_pos.x + grid_size/2 - fmod(mouse_pos.x + grid_size/2, grid_size),
						mouse_pos.y + grid_size/2 - fmod(mouse_pos.y + grid_size/2, grid_size))
	var grid_pos: Vector2 = (pos - Vector2(x_range[0],y_range[0]) - Vector2(32,32))/64
	var current_key: String = str(grid_pos)
	if current_key in building_dict.keys():
		if current_key != selected_key_for_repair:
			selected_key_for_repair = current_key
	else:
		selected_key_for_repair = ""

func rotate_part(direction: int) -> void:
	if instantiated_item != null:
		instantiated_item.rotate(0.5 * PI * direction)

func mirror_part() -> void:
	if instantiated_item != null:
		instantiated_item.scale *= Vector2(-1,1)

func instantiate_part(part: Part) -> void:
	instantiated_part = part
	instantiated_item = part.scene.instantiate()
	instantiated_item.part = part
	instantiated_item.visible = false
	add_child(instantiated_item)

func kill_selected_part() -> void:
	if instantiated_item != null:
		instantiated_item.queue_free()
		instantiated_part = null
		instantiated_item = null

func update_partlist() -> void:
	item_list.clear()
	var already_added_part: Array[Part]
	for part in Inventory.inventory:
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
	var selected_part: Part = null
	for part in Inventory.inventory:
		if part.name == selected_part_name:
			number_of_selected_part += 1
			if selected_part == null:
				selected_part = part
	item_info_label.text = str(number_of_selected_part, " in inventory")
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
		var possible_direction_array: Array[Vector2] = []
		if Part.POSSIBLE_NEIGHBORS.ALL in current_node.part.possible_neighbors:
			possible_direction_array = [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]
		else:
			for direction in current_node.part.possible_neighbors:
				# If mirrored mirror neighbor
				var mirror_vector: Vector2 = Vector2(1,1)
				if current_node.instance.scale == Vector2(-1,1):
					mirror_vector = Vector2(-1,1)
				var part_rot_in_rads: float = current_node.instance.rotation
				if direction == Part.POSSIBLE_NEIGHBORS.UP:
					possible_direction_array.append((Vector2.UP * mirror_vector).rotated(part_rot_in_rads).snappedf(1))
				elif direction == Part.POSSIBLE_NEIGHBORS.RIGHT:
					possible_direction_array.append((Vector2.RIGHT * mirror_vector).rotated(part_rot_in_rads).snappedf(1))
				elif direction == Part.POSSIBLE_NEIGHBORS.DOWN:
					possible_direction_array.append((Vector2.DOWN * mirror_vector).rotated(part_rot_in_rads).snappedf(1))
				elif direction == Part.POSSIBLE_NEIGHBORS.LEFT:
					possible_direction_array.append((Vector2.LEFT * mirror_vector).rotated(part_rot_in_rads).snappedf(1))
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
		# Set rotation to default as other wise rotation between part and the player will be unsynced
		player.rotation = 0
		player.mass = 0.001
		for node_key in building_dict.keys():
			var node = building_dict.get(node_key)
			player.mass += node.part.weight
			node.instance.parent = player
			node.instance.reparent(player.part_component)
			var off_set: Vector2 = (grid_dim-1    )/2.0 * Vector2(grid_size,grid_size)
			node.instance.position = node.grid_pos * Vector2(grid_size,grid_size) - off_set
			node.instance.attach(node_key)
		player.ship_graph = building_dict.duplicate(true)
		#ShipInfo.initialise_ship(building_dict, (y_range[1]-y_range[0])/64)
		clear_build_and_exit()

func clear_build_and_exit() -> void:
	# First clear any reference of part nodes
	if is_instance_valid(instantiated_item):
		instantiated_item.queue_free()
		instantiated_item = null
	instantiated_part = null
	selected_item_idx = 0
	current_mouse_pos = Vector2.ZERO
	
	# Then remove part nodes
	for child in get_children():
		if child is RigidBody2D:
			child.queue_free()
	
	build_complete.emit()
	get_tree().paused = false
