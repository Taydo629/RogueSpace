class_name ShipyardUI extends Control

@onready var current_upgrade_item: ItemSlot = $VBoxContainer/TabContainer/Upgrade/HBoxContainer/CurrentItem
@onready var new_upgrade_item: ItemSlot = $VBoxContainer/TabContainer/Upgrade/HBoxContainer/NewItem
@onready var current_repair_item: ItemSlot = $VBoxContainer/TabContainer/Repair/HBoxContainer/CurrentItem
@onready var new_repair_item: ItemSlot = $VBoxContainer/TabContainer/Repair/HBoxContainer/NewItem
@onready var inv_grid_container: GridContainer = $VBoxContainer/InventoryPanelContainer/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer/InvGridContainer
@onready var texture_rect: ColorRect = $BuildArea/TextureRect
@onready var build_area_rect: ColorRect = $BuildArea/BuildAreaRect
@onready var build_area: Control = $BuildArea
@onready var upgrade_button: Button = $VBoxContainer/TabContainer/Upgrade/HBoxContainer/VBoxContainer/UpgradeButton
@onready var repair_button: Button = $VBoxContainer/TabContainer/Repair/HBoxContainer/VBoxContainer/RepairButton
@onready var upgrade_cost_label: Label = $VBoxContainer/TabContainer/Upgrade/HBoxContainer/VBoxContainer/UpgradeCostLabel
@onready var margin_container: MarginContainer = $VBoxContainer/InventoryPanelContainer/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer
@onready var popup_control: Control = $PopupControl

enum BUILD_MODE {BUILD,REMOVE,SELECT}

var current_selected_item: Variant
var current_selected_base_part: BasePart
var current_node_key: String
var instantiated_item: Variant
@export var instantiated_item_modulate: Color
var current_mouse_pos: Vector2 = Vector2.ZERO

var player: Player
var building_dict: Dictionary = {}
var grid_dim: float = 5
var grid_size: float = 64
var y_range: Array
var x_range: Array
var build_mode: BUILD_MODE = BUILD_MODE.BUILD

const ITEM_ICON = preload("uid://0axhuylo0811")

signal build_complete
func _ready() -> void:
	init_ui()

#func _test_init_ui() -> void:
	#for i in 5:
		#var new_item_icon:ItemIcon = ITEM_ICON.instantiate()
		#new_item_icon.selected.connect(_add_to_part_to_slot)
		#inv_grid_container.add_child(new_item_icon)

func init_ui() -> void:
	_init_inv_grid()
	texture_rect.material.set_shader_parameter("grid_size", grid_size)
	var viewport_size: Vector2 = get_viewport_rect().size
	var grid_centre_x: float = int((viewport_size.x/grid_size)/2) * grid_size
	var grid_centre_y: float = int((viewport_size.y/grid_size)/2) * grid_size
	build_area_rect.scale = Vector2(grid_dim,grid_dim)
	#build_area_rect.global_position = Vector2(grid_centre_x,grid_centre_y)
	var grid_edge_dist_from_centre: float = grid_dim * grid_size / 2.0
	y_range = [grid_centre_y - grid_edge_dist_from_centre, grid_centre_y + grid_edge_dist_from_centre]
	x_range = [grid_centre_x - grid_edge_dist_from_centre, grid_centre_x + grid_edge_dist_from_centre]

func _init_inv_grid() -> void:
	_unselect_current_part()
	if not Inventory.inventory.is_empty():
		var parts_added: Array[Part] = []
		for item:Part in Inventory.inventory:
			if not item in parts_added:
				parts_added.append(item)
				var num_of_items: int = Inventory.inventory.count(item)
				var new_item_icon:ItemIcon = ITEM_ICON.instantiate()
				inv_grid_container.add_child(new_item_icon)
				new_item_icon.selected.connect(_add_to_part_to_slot)
				new_item_icon.out_of_parts.connect(_unselect_current_part)
				new_item_icon.item_count = num_of_items
				new_item_icon.part = item
				new_item_icon.popup_node = popup_control

func _clear_inv_grid() -> void:
	for item: ItemIcon in inv_grid_container.get_children():
		item.queue_free()

func _add_part_to_inventory(new_part: Part) -> void:
	for icon: ItemIcon in inv_grid_container.get_children():
		#var icon_part: Part = icon.part
		if new_part.name == icon.part.name and new_part.level == icon.part.level:
			print("found appropriate icon")
			icon.item_count = icon.item_count + 1
			return
	print("no icon found")
	var new_item_icon:ItemIcon = ITEM_ICON.instantiate()
	inv_grid_container.add_child(new_item_icon)
	new_item_icon.selected.connect(_add_to_part_to_slot)
	new_item_icon.out_of_parts.connect(_unselect_current_part)
	new_item_icon.item_count = 1
	new_item_icon.part = new_upgrade_item.part
	new_item_icon.popup_node = popup_control
	return
	
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

func _add_to_part_to_slot(selected_part: Part, icon: Variant, node_key: String = "") -> void:
	_unselect_current_part()
	current_node_key = node_key
	if current_selected_item is ItemIcon:
		current_selected_item.is_selected = false
	if icon is ItemIcon:
		current_selected_item = icon
	else:
		current_selected_item = null
		current_selected_base_part = icon
	current_upgrade_item.part = selected_part
	upgrade_cost_label.text = ""
	if selected_part.level != selected_part.level_dict.keys().max():
		print("part_is_upgradeable")
		var upgraded_part: Part = selected_part.duplicate_deep()
		# Increment part level by 1
		upgraded_part.level = selected_part.level + 1
		# Check if upgrade is affordable
		upgrade_cost_label.text = "%s CR" % upgraded_part.buy_price
		upgrade_button.text = "Upgrade"
		new_upgrade_item.part = upgraded_part
		if upgraded_part.buy_price > Inventory.wallet:
			upgrade_button.disabled = true
		else:
			upgrade_button.disabled = false
	else:
		upgrade_button.text = "Max Level"
		upgrade_button.disabled = true
		new_upgrade_item.reset_icon_to_default()
	current_repair_item.part = selected_part
	if build_mode == BUILD_MODE.BUILD:
		instantiate_part()

func _toggle_build_mode() -> void:
	if build_mode == BUILD_MODE.BUILD and current_selected_item is ItemIcon:
		instantiate_part()

func _unselect_current_part() -> void:
	if current_selected_item != null:
		current_selected_item.is_selected = false
		current_selected_item = null
		current_selected_base_part = null
		current_upgrade_item.reset_icon_to_default()
		new_upgrade_item.reset_icon_to_default()
		current_repair_item.reset_icon_to_default()
		new_repair_item.reset_icon_to_default()
		upgrade_button.text = "Upgrade"
		upgrade_cost_label.text = ""
		upgrade_button.disabled = true
	if instantiated_item != null:
		instantiated_item.queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		texture_rect.material.set_shader_parameter("mouse_pos", event.position)
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
			if build_mode == BUILD_MODE.BUILD:
				place_part()
			elif build_mode == BUILD_MODE.REMOVE:
				remove_part()
			else:
				pick_part()
			

func place_part() -> void:
	if current_mouse_pos != Vector2.ZERO and current_selected_item != null:
		var grid_pos: Vector2 = (Vector2(current_mouse_pos) - Vector2(x_range[0],y_range[0]) - Vector2(32,32))/64
		if str(grid_pos) not in building_dict.keys():
			var node_dict: Dictionary = {
				"part": current_selected_item.part,
				"instance": instantiated_item,
				"grid_pos": grid_pos,
				"rotation": instantiated_item.rotation,
				"scale": instantiated_item.scale,
				"health": instantiated_item.health
			}
			building_dict.set(str(grid_pos),node_dict)
			instantiate_part()
			Inventory.remove_item(current_selected_item.part)
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
			node.part.current_health = node.instance.health
			Inventory.add_item(node.part)
			building_dict.erase(str(grid_pos))
			print("Part removed")
		else:
			print("No part to remove!")
	else:
		print("Mouse out of bounds!")

func pick_part() -> void:
	if current_mouse_pos != Vector2.ZERO:
		var grid_pos: Vector2 = (Vector2(current_mouse_pos) - Vector2(x_range[0],y_range[0]) - Vector2(32,32))/64
		if str(grid_pos) in building_dict.keys():
			var node = building_dict.get(str(grid_pos))
			_add_to_part_to_slot(node.part, node.instance, str(grid_pos))
			print("Part picked")
		else:
			print("No part to pick!")
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
	if build_area_rect.get_rect().has_point(pos):
		if instantiated_item != null:
			instantiated_item.modulate = Color(1,1,1,1)
			instantiated_item.position = pos
			instantiated_item.visible = true
		current_mouse_pos = pos
	else:
		if instantiated_item != null:
			instantiated_item.modulate = instantiated_item_modulate
			instantiated_item.position = mouse_pos
			instantiated_item.visible = true
		current_mouse_pos = Vector2.ZERO

func rotate_part(direction: int) -> void:
	if instantiated_item != null:
		instantiated_item.rotate(0.5 * PI * direction)

func mirror_part() -> void:
	if instantiated_item != null:
		instantiated_item.scale *= Vector2(-1,1)

func instantiate_part() -> void:
	instantiated_item = current_selected_item.part.scene.instantiate()
	instantiated_item.part = current_selected_item.part
	instantiated_item.visible = false
	add_child(instantiated_item)

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

func _on_build_button_pressed() -> void:
	if building_dict.is_empty():
		print("No parts are placed!")
		return
	if assign_neighbors():
		# Set rotation to default as other wise rotation between part and the player will be unsynced
		player.rotation = 0
		player.mass = 0.001
		# Get core grid position and make it the center
		var pos_off_set: Vector2
		for node_key in building_dict.keys():
			var node = building_dict.get(node_key)
			if node.part.name == "core":
				pos_off_set = node.grid_pos * Vector2(grid_size,grid_size)
		for node_key in building_dict.keys():
			var node = building_dict.get(node_key)
			player.mass += node.part.weight
			node.instance.parent = player
			node.instance.reparent(player.part_component)
			#var off_set: Vector2 = (grid_dim-1    )/2.0 * Vector2(grid_size,grid_size)
			node.instance.position = node.grid_pos * Vector2(grid_size,grid_size) - pos_off_set
			node.instance.attach(node_key)
		player.ship_graph = building_dict.duplicate(true)
		clear_build_and_exit()

func clear_build_and_exit() -> void:
	# First clear any reference of part nodes
	_clear_inv_grid()
	if is_instance_valid(instantiated_item):
		instantiated_item.queue_free()
		instantiated_item = null
	current_selected_item = null
	current_mouse_pos = Vector2.ZERO
	
	# Then remove part nodes
	for child in build_area.get_children():
		if child is RigidBody2D:
			child.queue_free()
	
	build_complete.emit()


func _on_build_remove_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print("remove")
		_unselect_current_part()
		build_mode = BUILD_MODE.REMOVE
	else:
		print("build")
		build_mode = BUILD_MODE.BUILD


func _on_build_mode_dropdown_item_selected(index: int) -> void:
	if index == BUILD_MODE.BUILD:
		build_mode = BUILD_MODE.BUILD
	elif index == BUILD_MODE.REMOVE:
		build_mode = BUILD_MODE.REMOVE
	else:
		build_mode = BUILD_MODE.SELECT
	_toggle_build_mode()

func _on_upgrade_button_pressed() -> void:
	if current_selected_item is ItemIcon:
		#var current_part:Part = current_selected_item.part
		var upgraded_part:Part = new_upgrade_item.part
		var new_current_item_count: int = current_selected_item.item_count - 1
		if new_current_item_count > 0:
			current_selected_item.item_count = new_current_item_count
		else:
			current_selected_item.queue_free()
		call_deferred("_add_part_to_inventory", upgraded_part)
		Inventory.withdraw_from_wallet(upgraded_part.buy_price)
		Inventory.remove_item(current_upgrade_item.part)
		Inventory.add_item(new_upgrade_item.part)
	else:
		var current_part:Part = current_selected_base_part.part
		var upgraded_part:Part = current_part.duplicate_deep()
		upgraded_part.level += 1
		current_selected_base_part.part = upgraded_part
		Inventory.withdraw_from_wallet(upgraded_part.buy_price)
		if current_node_key != "":
			building_dict.get(current_node_key).part = new_upgrade_item.part
		_add_to_part_to_slot(current_selected_base_part.part, current_selected_base_part)
		print(current_selected_base_part.max_health)
