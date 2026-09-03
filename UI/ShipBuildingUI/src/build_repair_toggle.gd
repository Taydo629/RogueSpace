class_name BuildRepairToggle extends HBoxContainer
@onready var build_label: Label = $BuildLabel
@onready var repair_label: Label = $RepairLabel
@onready var build_repair_switch: CheckButton = $BuildRepairSwitch
var unselect_color: Color = Color(1,1,1,0.5)
var select_color: Color = Color(1,1,1,1)

signal build_mode
signal repair_mode

func _ready() -> void:
	_on_build_repair_switch_pressed()

func init() -> void:
	build_repair_switch.button_pressed = false
	build_label.modulate = select_color
	repair_label.modulate = unselect_color
	build_mode.emit()

func _on_build_repair_switch_pressed() -> void:
	if not build_repair_switch.button_pressed:
		build_label.modulate = select_color
		repair_label.modulate = unselect_color
		build_mode.emit()
	else:
		build_label.modulate = unselect_color
		repair_label.modulate = select_color
		repair_mode.emit()
