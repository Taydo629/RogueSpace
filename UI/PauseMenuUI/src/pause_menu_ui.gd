class_name PauseMenu extends Control

signal resume
signal option
signal guide

func _on_resume_button_pressed() -> void:
	resume.emit()

func _on_option_button_pressed() -> void:
	option.emit()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_guide_button_pressed() -> void:
	guide.emit()
