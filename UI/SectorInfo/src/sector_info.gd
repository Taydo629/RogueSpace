class_name SectorInfoUI extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel

signal enter_sector

func _on_continue_button_pressed() -> void:
	enter_sector.emit()
