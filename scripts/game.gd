extends Node2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("build_menu"):
		get_tree().change_scene_to_file("res://scenes/ship_building.tscn")
