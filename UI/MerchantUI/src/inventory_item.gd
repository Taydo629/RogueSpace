class_name InventoryItem extends VBoxContainer

var current_part_level: int
var hovered:bool = false:
	set(value):
		hovered = value
		if hovered:
			rich_text_label.visible = true
			texture_rect.visible = false
		else:
			rich_text_label.visible = false
			texture_rect.visible = true
var is_clicked: bool = false
var mouse_anchor_pos: Vector2
@export var click_grow: float = 1.2
@export var grow_time: float = 0.1

@onready var texture_rect: TextureRect = $PanelContainer/VBoxContainer/TextureRect
@onready var item_title_label: Label = $PanelContainer/VBoxContainer/ItemTitleLabel
@onready var panel_container: PanelContainer = $PanelContainer
@onready var rich_text_label: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
#@onready var h_separator: HSeparator = $PanelContainer/VBoxContainer/HSeparator

#signal clicked(icon: InventoryItem)
#signal unclicked(icon: InventoryItem)

var part: Part:
	set(value):
		part = value
		current_part_level = part.level
		texture_rect.texture = part.sprite
		item_title_label.text = str(part.display_name, " Lv %s" % part.level)
		_set_stats()

#func _ready() -> void:
	#_test()

#func _test() -> void:
	#const GUN = preload("uid://bs8ufgr7qnr1y")
	#part = GUN

func _get_drag_data(at_position: Vector2) -> Variant:
	var data = self
	var preview = Control.new()
	# So that icon is shown instead of stats
	hovered = false
	var preview_contents = self.duplicate()
	# Stop scripts from running as there is many scripts running
	preview_contents.set_script(null)
	# Off set the position so that it is inline with the cursor
	preview_contents.position = -0.5 * preview_contents.size
	preview.add_child(preview_contents)
	set_drag_preview(preview)
	
	# hide original node when dragging
	modulate.a = 0
	return data

#func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	#return false

#func _drop_data(at_position: Vector2, data: Variant) -> void:
	#pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("left_click") and hovered:
		#clicked.emit(self)
		#_on_clicked()
		#mouse_anchor_pos = get_local_mouse_position()
		#is_clicked = true
		#print("Clicked!")
	#elif Input.is_action_just_released("left_click") and hovered:
		#unclicked.emit(self)
		#_on_unclicked()
		#mouse_anchor_pos = Vector2.ZERO
		#is_clicked = false
		#print("Not clicked!")
	##elif is_clicked:
		##position += get_local_mouse_position() - mouse_anchor_pos

func _set_stats():
	rich_text_label.append_text(str("Value: %s" % part.sell_price, "\n"))
	rich_text_label.append_text(str("Max hp: %s" % part.max_health, "\n"))
	rich_text_label.append_text(str("Mass: %s" % part.weight, "\n"))
	if part.part_type == Part.PART_TYPE.THRUSTER:
		rich_text_label.append_text(str("Thrust: %s" % part.thrust_force, "\n"))
	elif part.part_type == Part.PART_TYPE.KINETIC_WEAPON:
		rich_text_label.append_text(str("Damage: %s" % part.damage, "\n"))
		rich_text_label.append_text(str("Fire rate: %s" % part.fire_rate, "\n"))
		rich_text_label.append_text(str("Speed: %s" % part.round_speed, "\n"))
		rich_text_label.append_text(str("Ammo cost: %s" % part.ammo_cost, "\n"))
	elif part.part_type == Part.PART_TYPE.ENERGY_WEAPON:
		rich_text_label.append_text(str("DPS: %s" % part.dps, "\n"))
		rich_text_label.append_text(str("Energy cost: %s" % part.energy_p_s, "\n"))

func _on_panel_container_mouse_entered() -> void:
	if not hovered:
		hovered = true
		#_on_hover()
		print("entered")

func _on_panel_container_mouse_exited() -> void:
	if not Rect2(Vector2(), panel_container.size).has_point(get_local_mouse_position()):
		hovered = false
		#_on_unhover()
		print("exited")

func _on_buy_button_pressed() -> void:
	Inventory.withdraw_from_wallet(part.buy_price)
	Inventory.add_item(part)
	queue_free()

func _on_clicked() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(panel_container, "offset_transform_scale", Vector2(click_grow,click_grow), grow_time)

func _on_unclicked() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(panel_container, "offset_transform_scale", Vector2(1,1), grow_time)

func unselect_item() -> bool:
	if not hovered:
		is_clicked = false
		set_instance_shader_parameter("selected", false)
		#_on_unhover()
		return true
	else:
		return false
