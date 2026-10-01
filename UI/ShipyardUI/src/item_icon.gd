class_name ItemIcon extends ItemSlot

var is_selected: bool = false:
	set(value):
		is_selected = value
		if is_selected:
			_selected()
		else:
			_unselected()
var selectable: bool = true:
	set(value):
		selectable = value
		if selectable:
			modulate = Color(1,1,1,1)
		else:
			modulate = disabled_modulate
var item_count: int:
	set(value):
		item_count = value
		count_label.text = "x %s" % item_count
signal selected(part: Part, icon: ItemIcon)
signal out_of_parts

@export var select_grow: float = 1.1
@export var grow_time: float = 0.2
@export var disabled_modulate: Color
@onready var count_label: Label = $PanelContainer/CounterControl/CountLabel

func _ready() -> void:
	Inventory.inventory_change.connect(_update_count)
	#_test()

#func _test() -> void:
	#const GUN = preload("uid://bs8ufgr7qnr1y")
	#part = GUN

func _update_count() -> void:
	if selectable:
		var new_count: int = _count_similar_parts(part)
		if item_count != new_count:
			item_count = new_count
		if item_count == 0:
			is_selected = false
			selectable = false
			out_of_parts.emit()
	else:
		var new_count: int = _count_similar_parts(part)
		if new_count > 0:
			item_count = new_count
			selectable = true

func _count_similar_parts(part_to_check: Part) -> int:
	var number_of_similar_parts: int = 0
	for part: Part in Inventory.inventory:
		if part_to_check.name == part.name and part_to_check.level == part.level:
			number_of_similar_parts += 1
	return number_of_similar_parts

func _process(_delta: float) -> void:
	if hovered:
		if not Rect2(Vector2(), panel_container.size).has_point(get_local_mouse_position()):
			hovered = false
			#_on_unhover()
	if Input.is_action_just_pressed("left_click") and hovered:
		if selectable:
			selected.emit(part, self)
			is_selected = true

func _selected() -> void:
	var tween: Tween = create_tween()
	z_index = 1
	tween.tween_property(panel_container, "offset_transform_scale", Vector2(select_grow,select_grow), grow_time)

func _unselected() -> void:
	var tween: Tween = create_tween()
	z_index = 0
	tween.tween_property(panel_container, "offset_transform_scale", Vector2(1,1), grow_time)
