class_name InputComponent extends Node

signal fire_guns
signal activate_thrusters
signal deactivate_thrusters
signal activate_tractorbeam
signal deactivate_tractorbeam
signal mouse_pos_changed

func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		fire_guns.emit()
	if Input.is_action_pressed("thrust"):
		activate_thrusters.emit()
	if Input.is_action_just_released("thrust"):
		deactivate_thrusters.emit()
	if Input.is_action_just_pressed("right_click"):
		activate_tractorbeam.emit()
	if Input.is_action_just_released("right_click"):
		deactivate_tractorbeam.emit()
	mouse_pos_changed.emit(get_parent().get_global_mouse_position())
