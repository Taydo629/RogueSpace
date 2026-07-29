extends CanvasLayer

@onready var resume_button: Button = $PauseMenuUI/VBoxContainer/ResumeButton
@onready var option_button: Button = $PauseMenuUI/VBoxContainer/OptionButton
@onready var exit_button: Button = $PauseMenuUI/VBoxContainer/ExitButton

signal resume
signal option
signal exit

func _on_resume_button_pressed() -> void:
	resume.emit()

func _on_option_button_pressed() -> void:
	option.emit()

func _on_exit_button_pressed() -> void:
	exit.emit()
