class_name ThrustComponent extends Node

@export var ship : RigidBody2D
@export var thrust_power : float = 2

var thrusters : Array

func _ready() -> void:
	var temp_thrusters = get_tree().get_nodes_in_group("thruster")
	for i in temp_thrusters:
		if i.get_parent() == get_parent():
			thrusters.append(i)

func update_thrusters() -> void:
	var temp_thrusters = get_tree().get_nodes_in_group("thruster")
	for i in temp_thrusters:
		if i.get_parent() == get_parent():
			thrusters.append(i)

func _physics_process(_delta: float) -> void:
	
	if Input.is_action_pressed("thrust"):
		for node in thrusters:
			if node != null:
				if not node is Node2D:
					continue
				node.cpu_particles_2d.emitting = true
				# 1. Calculate the local offset from the ship's origin to the thruster
				# global_transform.affine_inverse() converts a global position into the ship's local space
				var local_offset = ship.global_transform.affine_inverse() * node.global_position
				
				# 2. Calculate the force vector in GLOBAL space
				# If your thruster's "forward" is its own local UP direction:
				var thrust_direction = Vector2.UP.rotated(node.global_rotation)
				var global_force = thrust_direction * thrust_power
				
				# 3. Apply the force at the local offset
				ship.add_constant_force(global_force, local_offset)
	else:
		for node in thrusters:
			if node != null:
				if not node is Node2D:
					continue
				node.cpu_particles_2d.emitting = false
		ship.constant_force = Vector2.ZERO
