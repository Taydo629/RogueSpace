class_name MovementComponent extends Node

@export var gyro_strength: float = 10000.0
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
		thruster.cpu_particles_2d.emitting = true
		# 1. Calculate the local offset from the ship's origin to the thruster
		# global_transform.affine_inverse() converts a global position into the ship's local space
		#var local_offset = parent.global_transform.affine_inverse() * thruster.global_position
		
		# 2. Calculate the force vector in GLOBAL space
		# If your thruster's "forward" is its own local UP direction:
		var thrust_direction = Vector2.UP.rotated(thruster.global_rotation)
		var global_force = thrust_direction * thruster.thrust_force
		
		# 3. Apply the force at the local offset
		#parent.add_constant_force(global_force, local_offset)
		
		# Currently using more simplified method of thrust
		parent.add_constant_central_force(global_force)

func deactivate_thrusters() -> void:
	for thruster in thrusters:
		thruster.cpu_particles_2d.emitting = false
			
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
