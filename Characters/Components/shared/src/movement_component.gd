class_name MovementComponent extends Node

@export var gyro_strength: float = 300000.0
@export var dash_strength: float = 30000.0
@export var dash_energy_cost: float = 500.0
@export var dash_cooldown: float = 2
@export var dash_anim_time: float = 0.5
@export var p_gain: float = 1000
@export var d_gain: float = 1
var parent: RigidBody2D
var thrusters : Array[Thruster]
var timer: Timer
var dash_available: bool = true
var energy_component: EnergyComponent

func _ready() -> void:
	parent = get_parent()
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = dash_cooldown
	timer.timeout.connect(dash_reset)

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
		if thruster.scale == Vector2(1,-1):
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

func dash(direction: int) -> void:
	if dash_available:
		if not energy_component.use_energy(dash_energy_cost, energy_component.ENERGY_ROUTES.MOVEMENT):
			return
		else:
			var force_modifier: float = 1
			if energy_component != null:
				force_modifier = 1 + float(energy_component.energy_pips.get(energy_component.ENERGY_ROUTES.MOVEMENT).get("pips")) / float(energy_component.MAX_PIPS_PER_ROUTE)
			parent.dash_effect.direction = Vector2(direction, 0)
			parent.dash_effect.restart()
			parent.dash_effect.emitting = true
			dash_available = false
			timer.start()
			# If direction is 1 dash to right and if -1 to left.
			var dash_force: Vector2 = (direction * Vector2.RIGHT).rotated(parent.rotation) * dash_strength * force_modifier
			parent.apply_central_impulse(dash_force)

func dash_reset() -> void:
	dash_available = true

func rotate_to(target_pos: Vector2) -> void:
	var mass_adjusted_gyro_strength: float = gyro_strength * parent.mass
	var torque_modifier: float = 1
	if energy_component != null:
		torque_modifier = 1 + float(energy_component.energy_pips.get(energy_component.ENERGY_ROUTES.MOVEMENT).get("pips")) / float(energy_component.MAX_PIPS_PER_ROUTE)
	var angle_diff = get_angle_to_target(target_pos)
	var torque : float = angle_diff * gyro_strength * torque_modifier - parent.angular_velocity * gyro_strength / 2
	parent.apply_torque(torque)
	#if abs(angle_diff) >= 0.01:
		#parent.apply_torque(angle_diff * gyro_strength * torque_modifier)

func get_angle_to_target(target_pos: Vector2) -> float:
	var direction = (target_pos - parent.global_position).normalized()
	return (-parent.transform.y).angle_to(direction)
