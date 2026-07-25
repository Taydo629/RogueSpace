extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var direction_indicator: Control = $DirectionIndicator

func item_pickup(part: Part) -> void:
	h_box_container.pickup_notif(part)
