class_name GyroComponent extends Node

@export var gyro_strength: float = 10000
@export var ship : RigidBody2D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("yaw_R") and Input.is_action_pressed("yaw_L"):
		ship.constant_torque = 0
	elif Input.is_action_pressed("yaw_R"):
		ship.apply_torque(gyro_strength)
	elif Input.is_action_pressed("yaw_L"):
		ship.apply_torque(-gyro_strength)
	else:
		ship.constant_torque = 0
