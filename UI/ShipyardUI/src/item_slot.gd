class_name ItemSlot extends VBoxContainer

var current_part_level:int
var hovered:bool = false:
	set(value):
		hovered = value
		if hovered and part != null:
			if popup_node != null:
				control.reparent(popup_node)
			if tween != null:
				if tween.is_running():
					tween.stop()
			tween = create_tween()
			tween.tween_property(control, "offset_transform_scale", Vector2.ONE, 0.1)
			control.visible = true
		else:
			if tween.is_running():
				tween.stop()
			if popup_node != null:
				control.reparent(self)
			control.offset_transform_scale = Vector2.ZERO
			control.visible = false

var tween: Tween

@onready var control: Control = $Control
@onready var item_title_label: Label = $Control/PanelContainer/VBoxContainer/ItemTitleLabel
@onready var item_title_label_2: Label = $PanelContainer/VBoxContainer/ItemTitleLabel2
@onready var texture_rect: TextureRect = $PanelContainer/VBoxContainer/TextureRect
@onready var stats_label: RichTextLabel = $Control/PanelContainer/VBoxContainer/StatsLabel
@onready var description_label: RichTextLabel = $Control/PanelContainer/VBoxContainer/DescriptionLabel
@onready var panel_container: PanelContainer = $PanelContainer
@onready var pop_up_panel_container: PanelContainer = $Control/PanelContainer

@export var default_texture: Texture2D

var default_item_title_text: String = "Empty"
var default_description_text: String = "Select a part"
var default_stats_text: String = "Select a part"

var popup_node: Control

var part: Part:
	set(value):
		if value != null:
			part = value
			current_part_level = part.level
			texture_rect.texture = part.sprite
			item_title_label.text = str(part.display_name, " Lv %s" % part.level)
			item_title_label_2.text = str(part.display_name, " Lv %s" % part.level)
			description_label.text = part.part_description
			_set_stats()

func _process(_delta: float) -> void:
	if hovered:
		if not panel_container.get_rect().has_point(get_local_mouse_position()):
			hovered = false
			print("unhovered")

func _on_panel_container_mouse_entered() -> void:
	if not hovered:
		print("hovered")
		hovered = true
		#_on_hover()

func reset_icon_to_default() -> void:
	part = null
	texture_rect.texture = default_texture
	item_title_label.text = default_item_title_text
	description_label.text = default_description_text
	stats_label.text = default_stats_text

#func _on_panel_container_mouse_exited() -> void:
	#if not Rect2(Vector2(), panel_container.size).has_point(get_local_mouse_position()):
		#hovered = false
		##_on_unhover()

func _set_stats():
	stats_label.text = ""
	stats_label.append_text(str("Value: %s" % part.sell_price, "\n"))
	stats_label.append_text(str("Max hp: %s" % part.max_health, "\n"))
	stats_label.append_text(str("Mass: %s" % part.weight, "\n"))
	if part.part_type == Part.PART_TYPE.THRUSTER:
		stats_label.append_text(str("Thrust: %s" % part.thrust_force, "\n"))
	elif part.part_type == Part.PART_TYPE.KINETIC_WEAPON:
		stats_label.append_text(str("Damage: %s" % part.damage, "\n"))
		stats_label.append_text(str("Fire rate: %s" % part.fire_rate, "\n"))
		stats_label.append_text(str("Speed: %s" % part.round_speed, "\n"))
		stats_label.append_text(str("Ammo cost: %s" % part.ammo_cost, "\n"))
	elif part.part_type == Part.PART_TYPE.ENERGY_WEAPON:
		stats_label.append_text(str("DPS: %s" % part.dps, "\n"))
		stats_label.append_text(str("Energy cost: %s" % part.energy_p_s, "\n"))
