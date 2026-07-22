class_name EnemyAIInputComponent extends Node

signal fire_guns
signal activate_thrusters
signal deactivate_thrusters
signal activate_tractorbeam
signal deactivate_tractorbeam
signal target_coordinate

var target: Node2D
var trigger_pressed: bool = false

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
			target_coordinate.connect(sibling.rotate_to)

func _process(delta: float) -> void:
	if trigger_pressed:
		fire_guns.emit()
	#if Input.is_action_pressed("thrust"):
		#activate_thrusters.emit()
	#if Input.is_action_just_released("thrust"):
		#deactivate_thrusters.emit()
	#if Input.is_action_just_pressed("right_click"):
		#activate_tractorbeam.emit()
	#if Input.is_action_just_released("right_click"):
		#deactivate_tractorbeam.emit()
	if target != null:
		target_coordinate.emit(target.global_position)

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_ship"):
		target = body

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

func _on_fire_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_ship"):
		trigger_pressed = true

func _on_fire_area_body_exited(body: Node2D) -> void:
	if body == target:
		trigger_pressed = true
