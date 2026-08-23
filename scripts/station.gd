class_name Station extends StaticBody2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var label: Label = $Label

var main_game: Node2D

signal open_station_menu

#func _ready() -> void:
	#if main_game != null:
		#open_station_menu.connect(main_game.enter_station)

func _process(delta: float) -> void:
	if interaction_area.has_overlapping_bodies():
		var is_player_in_range: bool = false
		for body in interaction_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				is_player_in_range = true
		label.visible = is_player_in_range
	else:
		label.visible = false
	
	if Input.is_action_just_pressed("e"):
		if label.visible:
			open_station_menu.emit()
