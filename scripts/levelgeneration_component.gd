class_name LevelGenComponent extends Node

signal level_generated

func generate_level(level_number: int) -> void:
	# code to generate level
	level_generated.emit()
