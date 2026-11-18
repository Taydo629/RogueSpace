class_name DroneInputComponent extends Node

signal fire_guns
signal activate_thrusters
signal deactivate_thrusters
#signal activate_tractorbeam
#signal deactivate_tractorbeam
signal target_pos_changed

var parent: RigidBody2D
var anchor_pos: Vector2
var target_ship: RigidBody2D
var search_for_target: bool = false
var enroute_to_way_point: bool = false
var searching_error: int = 1000
var detection_area: Area2D
var wander_range: int
var target_pos: Vector2
var timer: Timer
@export var tracking_time: int = 5
@export var min_engage_distance: int = 800

func _ready() -> void:
	parent = get_parent()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_disengage_target)
	timer.wait_time = tracking_time

func init_input() -> void:
	detection_area.body_entered.connect(_body_entered_detection_range)
	detection_area.body_exited.connect(_body_exited_detection_range)

func _process(_delta: float) -> void:
	target_processing()
	var thrusters_on: bool = thruster_processing()
	if trigger_proccessing():
		fire_guns.emit()
	if thrusters_on:
		activate_thrusters.emit()
	if not thrusters_on:
		deactivate_thrusters.emit()
	#if Input.is_action_just_pressed("right_click"):
		#activate_tractorbeam.emit()
	#if Input.is_action_just_released("right_click"):
		#deactivate_tractorbeam.emit()
	target_pos_changed.emit(target_pos)

func _body_entered_detection_range(body: Node2D) -> void:
	# If body is player start set the target ship
	if body.is_in_group("player"):
		timer.stop()
		target_ship = body
		print("Player entered detection range!")

func _body_exited_detection_range(body: Node2D) -> void:
	# If the player exits detection start a timer for time to continue tracking
	if body.is_in_group("player"):
		print("Player exited detection range!")
		search_for_target = true
		timer.start()

func _disengage_target() -> void:
	print("Disengaging target!")
	search_for_target = false
	target_ship = null
	
func target_processing() -> void:
	if target_ship != null:
		enroute_to_way_point = false
		var target_ship_pos: Vector2 = target_ship.global_position
		if search_for_target:
			target_ship_pos += Vector2(randi_range(-1000,1000),randi_range(-1000,1000))
		target_pos = target_ship_pos
	else:
		if not enroute_to_way_point:
			target_pos = Vector2.UP.rotated(randf_range(0, 2 * PI)) * randi_range(0,wander_range)
			enroute_to_way_point = true
		else:
			if parent.global_position.distance_to(target_pos) < 100:
				enroute_to_way_point = false

func thruster_processing() -> bool:
	var direction = (target_pos - get_parent().global_position).normalized()
	var abs_angle_to_target: float = abs((-get_parent().transform.y).angle_to(direction))
	if abs_angle_to_target < PI * 0.25:
		if target_ship != null:
			if parent.global_position.distance_to(target_ship.global_position) < min_engage_distance:
				return false
		return true
	else:
		return false

func trigger_proccessing() -> bool:
	if target_ship != null:
		var direction = (target_pos - get_parent().global_position).normalized()
		var abs_angle_to_target: float = abs((-get_parent().transform.y).angle_to(direction))
		if abs_angle_to_target < 0.5 * PI:
			return true
		else:
			return false
	else:
		return false
	
