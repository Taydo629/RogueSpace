extends Node

var player_camera: PlayerCamera

func apply_camera_shake(magnitude: float) -> void:
	if player_camera != null:
		player_camera.camera_shake(magnitude)
