class_name GyroComponent extends Node

@export var gyro_strength: float = 10000.0
var active_ship: RigidBody2D = null

#func _physics_process(delta: float) -> void:
	#if not is_instance_valid(active_ship):
		#return
		#
	#var rotation_dir = Input.get_axis("yaw_L", "yaw_R")
	#
	#if rotation_dir != 0:
		## Apply continuous frame-based force directly to the parent rigid body
		#active_ship.apply_torque(rotation_dir * gyro_strength * delta)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(active_ship):
		return
	if Input.is_action_pressed("yaw_R") and Input.is_action_pressed("yaw_L"):
		active_ship.constant_torque = 0
	elif Input.is_action_pressed("yaw_R"):
		active_ship.apply_torque(gyro_strength)
	elif Input.is_action_pressed("yaw_L"):
		active_ship.apply_torque(-gyro_strength)
	else:
		active_ship.constant_torque = 0
	
