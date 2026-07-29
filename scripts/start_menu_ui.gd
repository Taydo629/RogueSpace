extends CanvasLayer

@onready var start_button: Button = $StartMenuUI/VBoxContainer/StartButton
@onready var option_button: Button = $StartMenuUI/VBoxContainer/OptionButton
@onready var exit_button: Button = $StartMenuUI/VBoxContainer/ExitButton

signal start
signal option
signal exit

func _on_start_button_pressed() -> void:
	start.emit()

func _on_option_button_pressed() -> void:
	option.emit()

func _on_exit_button_pressed() -> void:
	exit.emit()
