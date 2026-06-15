class_name ThrustComponent extends Node

@export var ship : RigidBody2D

var thrusters : Array

func _ready() -> void:
	thrusters = get_tree().get_nodes_in_group("thruster")

func _physics_process(delta: float) -> void:
	for node in thrusters:
		var default_force = Vector2.UP
		var current_angle = ship.rotation
		var new_force = default_force.rotated(current_angle)
		print(current_angle)
		print(new_force)
		ship.add_constant_force(new_force, node.position - ship.position)
		#print(node.global_position)
