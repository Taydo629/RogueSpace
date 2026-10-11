class_name DroneMovementComponent extends Node

enum STATE{PATROL, SEARCH, ATTACK}

var current_state: STATE = STATE.PATROL
var player: Player
var target_position: Vector2
var patrol_position: Vector2 = Vector2(0,0)
var parent: Drone

@export var gyro_strength: float = 300000.0
@export var patrol_radius: float = 2500
@export var thrust_force: float
@export var view_range: float
@export var damage_per_shot: float
@export var max_speed: float = 5000

func _ready() -> void:
	parent = get_parent()

func _physics_process(delta: float) -> void:
	if current_state == STATE.PATROL:
		_patrol()
	elif current_state == STATE.SEARCH:
		_search()
	else:
		_attack()

func _patrol() -> void:
	if patrol_position != null:
		var target_vec: Vector2
		if parent.position.distance_to(patrol_position) > patrol_radius*1.1:
			# Logic if drone is away from patrol radius
			rotate_to(patrol_position)
			target_vec = Vector2.UP.rotated(parent.rotation + get_angle_to_target(patrol_position))
		elif parent.position.distance_to(patrol_position) < patrol_radius*0.9:
			# Logic if drone is too close in patrol radius
			var target_pos = patrol_position + (parent.position - patrol_position).normalized() * patrol_radius
			rotate_to(target_pos)
			target_vec = Vector2.UP.rotated(parent.rotation + get_angle_to_target(target_pos))
		else:
			# Logic once drone is inside patrol radius
			var vec_to_center = (patrol_position - parent.position).normalized()
			var tangent = vec_to_center.rotated(0.5 * PI)
			rotate_to(parent.position + tangent)
			
			var v: float = parent.linear_velocity.length()
			var r: float = max(parent.position.distance_to(patrol_position), 0.1)
			var centrepetal_magnitude = (parent.mass * pow(v, 2))/r
			target_vec = (tangent + (vec_to_center * (centrepetal_magnitude / max_speed))).normalized() 
		parent.apply_central_force(max_speed*target_vec)

func _search() -> void:
	pass

func _attack() -> void:
	pass

func rotate_to(target_pos: Vector2) -> void:
	var torque_modifier: float = 1
	var angle_diff = get_angle_to_target(target_pos)
	var torque : float = angle_diff * gyro_strength - parent.angular_velocity * gyro_strength / 2
	parent.apply_torque(torque)
	#if abs(angle_diff) >= 0.01:
		#parent.apply_torque(angle_diff * gyro_strength * torque_modifier)

func get_angle_to_target(target_pos: Vector2) -> float:
	var direction = (target_pos - parent.global_position).normalized()
	return (-parent.transform.y).angle_to(direction)
