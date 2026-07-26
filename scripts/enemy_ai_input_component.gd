class_name EnemyAIInputComponent extends Node

signal fire_guns
signal activate_thrusters
signal deactivate_thrusters
signal activate_tractorbeam
signal deactivate_tractorbeam
signal target_coordinate

var target: Node2D
var poi: Vector2
var original_pos: Vector2
var trigger_pressed: bool = false
var fleeing: bool = false
@export var thrust_component: ThrustComponent
@export var gyro_component: GyroComponent

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
	original_pos = get_parent().global_position
	find_new_poi()
	
func _process(delta: float) -> void:
	if trigger_pressed:
		fire_guns.emit()
	if thrust_component != null:
		var target_pos: Vector2
		if target != null:
			target_pos = target.global_position
			var angle_to_target: float = abs(gyro_component.get_angle_to_target(target_pos))
			if angle_to_target <= 0.1*PI and distance_to_target() >= 700:
				activate_thrusters.emit()
			else:
				if not fleeing:
					deactivate_thrusters.emit()
		else:
			target_pos = poi
			var angle_to_target: float = abs(gyro_component.get_angle_to_target(target_pos))
			if angle_to_target <= 0.1*PI:
				activate_thrusters.emit()
			else:
				deactivate_thrusters.emit()
	#if Input.is_action_just_pressed("right_click"):
		#activate_tractorbeam.emit()
	#if Input.is_action_just_released("right_click"):
		#deactivate_tractorbeam.emit()
	if target != null:
		var target_pos: Vector2 = target.global_position
		if distance_to_target() <= 400:
			target_pos = (target_pos - get_parent().global_position).rotated(2*PI)
			fleeing = true
		else:
			fleeing = false
		activate_thrusters.emit()
		target_coordinate.emit(target_pos)
	else:
		target_coordinate.emit(poi)
	
	# Target new poi if we approach close enough
	if get_parent().global_position.distance_to(poi) <= 100:
		find_new_poi()
	
func distance_to_target() -> float:
	return get_parent().global_position.distance_to(target.global_position)

func find_new_poi() -> void:
	poi = original_pos + Vector2(randi_range(-1600,1600),randi_range(-1600,1600))

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
		trigger_pressed = false
