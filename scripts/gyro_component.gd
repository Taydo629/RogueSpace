class_name GyroComponent extends Node

@export var gyro_strength: float = 10000.0
var active_ship: RigidBody2D = null

# Old gyro movement: keeping in case wanted later
#func _physics_process(delta: float) -> void:
	#if not is_instance_valid(active_ship):
		#return
	#if Input.is_action_pressed("yaw_R") and Input.is_action_pressed("yaw_L"):
		#active_ship.constant_torque = 0
	#elif Input.is_action_pressed("yaw_R"):
		#active_ship.apply_torque(gyro_strength)
	#elif Input.is_action_pressed("yaw_L"):
		#active_ship.apply_torque(-gyro_strength)
	#else:
		#active_ship.constant_torque = 0

func rotate_to(target_pos: Vector2) -> void:
	var direction = (target_pos - get_parent().global_position).normalized()
	var angle_diff = (-get_parent().transform.y).angle_to(direction)
	if abs(angle_diff) >= 0.01:
		get_parent().apply_torque(angle_diff * gyro_strength)
