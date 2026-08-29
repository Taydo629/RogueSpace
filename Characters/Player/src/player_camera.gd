class_name PlayerCamera extends Camera2D

var current_zoom: float

@export var min_zoom: float = 0.1
@export var max_zoom: float = 1.0
@export var zoom_increment: float = 0.1

func _ready() -> void:
	current_zoom = zoom.x

func zoom_in() -> void:
	var new_zoom: float = current_zoom + zoom_increment
	if new_zoom < max_zoom:
		current_zoom = new_zoom
		zoom = Vector2(current_zoom,current_zoom)
	else:
		pass

func zoom_out() -> void:
	var new_zoom: float = current_zoom - zoom_increment
	if new_zoom > min_zoom:
		current_zoom = new_zoom
		zoom = Vector2(current_zoom,current_zoom)
	else:
		pass
