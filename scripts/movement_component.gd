class_name MovementComponent extends Node

var player: Player
var thrusters : Array[Thruster]

func _ready() -> void:
	player = get_parent()

func initalise_movement() -> void:
	thrusters = []
	var ship_graph = ShipInfo.ship_graph
	for node in ship_graph.values():
		if node.instance.is_in_group("thruster"):
			thrusters.append(node.instance)
	activate_thrusters()

func activate_thrusters() -> void:
	for thruster in thrusters:
		thruster.cpu_particles_2d.emitting = true
		# 1. Calculate the local offset from the ship's origin to the thruster
		# global_transform.affine_inverse() converts a global position into the ship's local space
		#var local_offset = player.global_transform.affine_inverse() * node.global_position
		
		# 2. Calculate the force vector in GLOBAL space
		# If your thruster's "forward" is its own local UP direction:
		var thrust_direction = Vector2.UP.rotated(thruster.global_rotation)
		var global_force = thrust_direction * thruster.thrust_force
		
		# 3. Apply the force at the local offset
		#ship.add_constant_force(global_force, local_offset)
		
		# Currently using more simplified method of thrust
		print(player)
		player.add_constant_central_force(global_force)
