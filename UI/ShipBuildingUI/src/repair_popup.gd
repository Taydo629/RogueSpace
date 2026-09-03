class_name RepairPopup extends Panel

var min_slider_value: float
@onready var h_slider: HSlider = $MarginContainer/VBoxContainer/HSlider
var current_part: Part
var current_part_instance: BasePart
@onready var current_health_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CurrentHealthLabel
@onready var new_health_lab: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NewHealthLab
@onready var repair_cost_lab: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RepairCostLab
@onready var repair_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/RepairButton
@onready var credit_ui: Label = $"../CreditUI"
var parent: BuildUI
@export var popup_anim_dur: float = 0.1

func _on_exit_button_pressed() -> void:
	exit_popup()

func open_popup() -> void:
	scale = Vector2(1,0)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1),popup_anim_dur)
	visible = true

func init_slider(part_instance: BasePart, part: Part) -> void:
	current_part_instance = part_instance
	current_part = part
	min_slider_value = (float(current_part_instance.health)/float(current_part_instance.max_health))*100.
	h_slider.set_value_no_signal(min_slider_value)
	update_info()

func _on_h_slider_value_changed(value: float) -> void:
	if value < min_slider_value:
		h_slider.value = min_slider_value
	else:
		update_info()

func update_info() -> void:
	var cost_to_repair: float = ((h_slider.value - min_slider_value)/100.) * current_part.sell_price
	var current_health_str: String = "Current health: %s%%"
	var new_health_str: String = "New health: %s%%"
	var repair_cost_str: String = "Repair cost: %s"
	current_health_label.text = current_health_str % str(min_slider_value)
	new_health_lab.text = new_health_str % str(h_slider.value)
	repair_cost_lab.text = repair_cost_str % cost_to_repair

func _on_repair_button_pressed() -> void:
	var repair_cost: float = ((h_slider.value - min_slider_value)/100.) * current_part.sell_price
	if Inventory.withdraw_from_wallet(repair_cost):
		var healed_health: int = int((h_slider.value/100.)*current_part_instance.max_health) - current_part_instance.health
		current_part_instance.heal(healed_health)
		exit_popup()
		parent.update_credit()

func exit_popup() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,0),popup_anim_dur)
	tween.tween_callback(hide)
	current_part_instance = null
	current_part = null
	min_slider_value = 0
