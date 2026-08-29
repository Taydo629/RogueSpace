class_name MovementComponent extends Node

@export var gyro_strength: float = 300000.0
var parent: RigidBody2D
var thrusters : Array[Thruster]

func _ready() -> void:
	parent = get_parent()

func initalise_movement(ship_graph: Dictionary) -> void:
	thrusters = []
	for node in ship_graph.values():
		if node.instance.is_in_group("thruster"):
			thrusters.append(node.instance)

func activate_thrusters() -> void:
	for thruster in thrusters:
		thruster.thruster_particles.emitting = true
		thruster.thruster_light.enabled = true
		if not thruster.thruster_sound.playing:
			thruster.thruster_sound.playing = true
		var up_vector: Vector2
		if thruster.scale == Vector2(-1,1):
			up_vector = Vector2.DOWN
		else:
			up_vector = Vector2.UP
		var thrust_direction = up_vector.rotated(thruster.global_rotation)
		var global_force = thrust_direction * thruster.thrust_force
		parent.add_constant_central_force(global_force)

func deactivate_thrusters() -> void:
	for thruster in thrusters:
		thruster.thruster_particles.emitting = false
		thruster.thruster_light.enabled = false
		if thruster.thruster_sound.playing:
			thruster.thruster_sound.playing = false
			
	parent.constant_force = Vector2.ZERO
	#if thruster_sound.playing == true:
		#thruster_sound.playing = false

func rotate_to(target_pos: Vector2) -> void:
	var angle_diff = get_angle_to_target(target_pos)
	if abs(angle_diff) >= 0.01:
		parent.apply_torque(angle_diff * gyro_strength)

func get_angle_to_target(target_pos: Vector2) -> float:
	var direction = (target_pos - parent.global_position).normalized()
	return (-parent.transform.y).angle_to(direction)
