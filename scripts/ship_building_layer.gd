extends CanvasLayer

@onready var item_list: ItemList = $ShipBuildingUI/FoldableContainer/Control/ItemList
@onready var item_info_label: Label = $ShipBuildingUI/FoldableContainer/Control/ItemInfoLabel

var instantiated_item: RigidBody2D
var instantiated_part: Part

var y_range: Array = [128,512]
var x_range: Array = [384,768]

func _ready() -> void:
	update_partlist()

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and instantiated_item != null:
		move_part(event.position)
	elif event is InputEventKey:
		if event.as_text_keycode() == "E" and event.pressed == true:
			rotate_part(1)
		elif event.as_text_keycode() == "Q" and event.pressed == true:
			rotate_part(-1)
		elif event.as_text_keycode() == "M" and event.pressed == true:
			mirror_part()

func move_part(position: Vector2) -> void:
	## Get the grid position so that parts are on a grid.
	var mouse_pos = position
	var pos = Vector2(mouse_pos.x -fmod(mouse_pos.x, 64),mouse_pos.y -fmod(mouse_pos.y, 64)) + Vector2(32,32)
	# Handle parts positioning and handle when mouse pos is outside of building area.
	if pos.x >= x_range[0] and pos.x <= x_range[1] and pos.y <= y_range[1] and pos.y >= y_range[0] :
		instantiated_item.visible = true
		instantiated_item.position = pos
	else:
		instantiated_item.visible = false
	instantiated_item.position = pos

func rotate_part(direction: int) -> void:
	instantiated_item.rotate(0.5 * PI * direction)

func mirror_part() -> void:
	instantiated_item.scale *= Vector2(-1,1)

func instantiate_part(part: Part) -> void:
	instantiated_part = part
	instantiated_item = part.scene.instantiate()
	instantiated_item.visible = false
	add_child(instantiated_item)

func kill_selected_part() -> void:
	instantiated_item.queue_free()
	instantiated_part = null
	instantiated_item = null

func update_partlist() -> void:
	var already_added_part: Array[Part]
	for part in Inventory.inventory:
		if part not in already_added_part:
			item_list.add_item(part.name, part.image)
			already_added_part.append(part)

func update_partinfo(idx: int) -> Part:
	var number_of_selected_part:int = 0
	var selected_part_name: String = item_list.get_item_text(idx)
	var selected_part: Part
	for part in Inventory.inventory:
		if part.name == selected_part_name:
			number_of_selected_part += 1
			if selected_part == null:
				selected_part = part
	item_info_label.text = str(number_of_selected_part, " in inventory")
	return selected_part

func _on_item_list_item_selected(index: int) -> void:
	var selected_part = update_partinfo(index)
	
	if selected_part != null:
		instantiate_part(selected_part)
	else:
		kill_selected_part()
		instantiate_part(selected_part)
