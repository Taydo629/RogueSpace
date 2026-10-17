class_name StartMenu extends Control

@onready var color_rect: ColorRect = $ColorRect

signal start
signal option
signal guide

@export var UI_transition_time: float = 0.5

func init_ui() -> void:
	print("Initializing main menu")
	_transition(true)
	
func _on_start_button_pressed() -> void:
	var transition_tween = _transition(false)
	transition_tween.finished.connect(start.emit)

func _on_option_button_pressed() -> void:
	print_debug("Not implemented")
	#var transition_tween = _transition(false)
	#transition_tween.finished.connect(option.emit)

func _on_exit_button_pressed() -> void:
	var transition_tween = _transition(false)
	transition_tween.finished.connect(get_tree().quit)

func _on_guide_button_pressed() -> void:
	var transition_tween = _transition(false)
	transition_tween.finished.connect(guide.emit)

func _transition(start: bool) -> Tween:
	var target: float = 1.0
	if start:
		color_rect.set_instance_shader_parameter("dissolve_progress", 1.0)
		target = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "instance_shader_parameters/dissolve_progress", target, UI_transition_time)
	return tween
