class_name EnemyBlip extends Polygon2D

var parent: TextureRect
var enemy: npc
var player: Player
var max_alpha: float = 0.8
var min_alpha: float = 0.0
var color_rgb: Vector3
var distance_to_player: float
@export var flicker_time: float = 1.0

func _ready() -> void:
	if get_parent() is TextureRect:
		parent = get_parent()
	color.a = max_alpha

func _process(delta: float) -> void:
	_flicker()

func _flicker() -> void:
	var target_color: Color = color
	if is_equal_approx(color.a, max_alpha):
		var tween:= create_tween()
		target_color.a = min_alpha
		print(color)
		tween.tween_property(self, "color", target_color, flicker_time)
	if is_equal_approx(color.a, min_alpha):
		var tween:= create_tween()
		target_color.a = max_alpha
		tween.tween_property(self, "color", target_color, flicker_time)
