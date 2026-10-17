class_name PlayerCamera extends Camera2D

var current_zoom: float

@export var min_zoom: float = 0.1
@export var max_zoom: float = 1.0
@export var zoom_increment: float = 0.1
@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(100,75)
@export var max_roll: float = 0.1
@export var follow_node: Node2D

var rng = RandomNumberGenerator.new()
var shake: float = 0
var shake_power: int = 2

func _ready() -> void:
	randomize()
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

func shake_cam() -> void:
	var amount = pow(shake, shake_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func _process(delta: float) -> void:
	if shake:
		shake = max(shake - decay * delta, 0)
		shake_cam()

func add_shake(magnitude: float) -> void:
	if shake < magnitude:
		shake = min(shake + magnitude, 1.0)
