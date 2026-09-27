class_name ItemSlot extends VBoxContainer

var current_part_level:int
var hovered:bool = false:
	set(value):
		hovered = value
		if hovered:
			stats_label.visible = true
			description_label.visible = false
		else:
			stats_label.visible = false
			description_label.visible = true

@onready var item_title_label: Label = $PanelContainer/VBoxContainer/ItemTitleLabel
@onready var texture_rect: TextureRect = $PanelContainer/VBoxContainer/TextureRect
@onready var stats_label: RichTextLabel = $PanelContainer/VBoxContainer/StatsLabel
@onready var description_label: RichTextLabel = $PanelContainer/VBoxContainer/DescriptionLabel
@onready var panel_container: PanelContainer = $PanelContainer

var part: Part:
	set(value):
		part = value
		current_part_level = part.level
		texture_rect.texture = part.sprite
		item_title_label.text = str(part.display_name, " Lv %s" % part.level)
		description_label.text = part.part_description
		_set_stats()

func _process(delta: float) -> void:
	if hovered:
		if panel_container.get_rect().has_point(get_local_mouse_position()):
			hovered = false

func _on_panel_container_mouse_entered() -> void:
	if not hovered:
		hovered = true
		#_on_hover()

#func _on_panel_container_mouse_exited() -> void:
	#if not Rect2(Vector2(), panel_container.size).has_point(get_local_mouse_position()):
		#hovered = false
		##_on_unhover()

func _set_stats():
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
