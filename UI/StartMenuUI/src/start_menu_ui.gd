class_name StartMenu extends Control

signal start
signal option
signal guide

func _on_start_button_pressed() -> void:
	start.emit()

func _on_option_button_pressed() -> void:
	option.emit()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_guide_button_pressed() -> void:
	guide.emit()
