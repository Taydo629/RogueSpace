extends Node

signal fire_guns
signal activate_thrusters
signal deactivate_thrusters
signal activate_tractorbeam
signal deactivate_tractorbeam
signal mouse_pos_changed

func _ready() -> void:
	var sibling_array: Array = get_parent().get_children()
	for sibling in sibling_array:
		if sibling.has_method("fire"):
			fire_guns.connect(sibling.fire)
		if sibling.has_method("thrusters_on"):
			activate_thrusters.connect(sibling.thrusters_on)
		if sibling.has_method("thrusters_off"):
			deactivate_thrusters.connect(sibling.thrusters_off)
		if sibling.has_method("activate_tractorbeam"):
			activate_tractorbeam.connect(sibling.activate_tractorbeam)
		if sibling.has_method("deactivate_tractorbeam"):
			deactivate_tractorbeam.connect(sibling.deactivate_tractorbeam)
		if sibling.has_method("rotate_to"):
			mouse_pos_changed.connect(sibling.rotate_to)

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
