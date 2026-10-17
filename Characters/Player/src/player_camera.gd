class_name PlayerCamera extends Camera2D

var current_zoom: float

@export var min_zoom: float = 0.1
@export var max_zoom: float = 1.0
@export var zoom_increment: float = 0.1
@export var shake_fade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func _ready() -> void:
	current_zoom = zoom.x
	CameraManager.player_camera = self

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

func camera_shake(magnitude: float) -> void:
	shake_strength = magnitude

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		offset = random_offset()
		
func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
