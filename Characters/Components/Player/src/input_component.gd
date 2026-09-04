class_name InputComponent extends Node

signal fire_guns
signal activate_thrusters
signal deactivate_thrusters
signal activate_tractorbeam
signal deactivate_tractorbeam
signal mouse_pos_changed
signal zoom_in
signal zoom_out
signal dash(int)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		fire_guns.emit()
	if Input.is_action_pressed("w"):
		activate_thrusters.emit()
	if Input.is_action_just_released("w"):
		deactivate_thrusters.emit()
	if Input.is_action_just_pressed("right_click"):
		activate_tractorbeam.emit()
	if Input.is_action_just_released("right_click"):
		deactivate_tractorbeam.emit()
	if Input.is_action_just_pressed("scroll_up"):
		zoom_in.emit()
	if Input.is_action_just_pressed("scroll_down"):
		zoom_out.emit()
	if Input.is_action_pressed("yaw_L"):
		dash.emit(-1)
	if Input.is_action_pressed("yaw_R"):
		dash.emit(1)
	mouse_pos_changed.emit(get_parent().get_global_mouse_position())
