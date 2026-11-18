class_name MerchantItem extends VBoxContainer

var current_part_level: int
var hovered:bool = false:
	set(value):
		hovered = value
		if hovered:
			rich_text_label.visible = true
			item_description_label.visible = false
		else:
			rich_text_label.visible = false
			item_description_label.visible = true
var is_hovered: bool = false
var is_selected: bool = false

@export var hover_grow: float = 1.2
@export var grow_time: float = 0.2

@onready var texture_rect: TextureRect = $PanelContainer/VBoxContainer/TextureRect
@onready var item_description_label: RichTextLabel = $PanelContainer/VBoxContainer/ItemDescriptionLabel
@onready var item_title_label: Label = $PanelContainer/VBoxContainer/ItemTitleLabel
@onready var panel_container: PanelContainer = $PanelContainer
@onready var rich_text_label: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var buy_button: Button = $BuyButton
#@onready var h_separator: HSeparator = $PanelContainer/VBoxContainer/HSeparator

signal selected(QuadrantIcon)

var part: Part:
	set(value):
		part = value
		current_part_level = part.level
		texture_rect.texture = part.sprite
		item_title_label.text = str(part.display_name, " Lv %s" % part.level)
		item_description_label.text = part.part_description
		buy_button.text = str("Buy (%sCR)" % part.buy_price)
		_set_stats()
		check_affordable()

#func _ready() -> void:
	#_test()
#
#func _test() -> void:
	#const GUN = preload("uid://bs8ufgr7qnr1y")
	#part = GUN

func _set_stats():
	print("hey")
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
		_on_hover()
		print("entered")

func _on_panel_container_mouse_exited() -> void:
	if not Rect2(Vector2(), panel_container.size).has_point(get_local_mouse_position()):
		hovered = false
		_on_unhover()
		print("exited")

func _on_buy_button_pressed() -> void:
	Inventory.withdraw_from_wallet(part.buy_price)
	Inventory.add_item(part)
	queue_free()
		

func _unaffordable() -> void:
	buy_button.disabled = true

func _affordable() -> void:
	buy_button.disabled = false

func _on_hover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(panel_container, "offset_transform_scale", Vector2(hover_grow,hover_grow), grow_time)

func _on_unhover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(panel_container, "offset_transform_scale", Vector2(1,1), grow_time)

func unselect_item() -> bool:
	if not is_hovered:
		is_selected = false
		set_instance_shader_parameter("selected", false)
		_on_unhover()
		return true
	else:
		return false

func check_affordable() -> void:
	if part.buy_price > Inventory.wallet:
		_unaffordable()
	else:
		_affordable()
