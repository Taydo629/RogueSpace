extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer

func item_pickup(part: Part) -> void:
	h_box_container.pickup_notif(part)
