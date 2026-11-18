class_name EnemyBlip extends Polygon2D

var parent: TextureRect
var enemy: npc
var player: Player
var radar_center_pos: Vector2
var radar_circle_radius: float
var radar_range: float
var distance_to_player: float
var flicker_time: float = 0.0
@export var max_flicker_speed: float = 10.0
@export var min_flicker_speed: float = 4.0

func _ready() -> void:
	if get_parent() is TextureRect:
		parent = get_parent()

func _process(delta: float) -> void:
	_move_blip(delta)
	if enemy == null:
		_kill_blip()

func _move_blip(delta: float) -> void:
	if player == null or enemy == null:
		return
	var distance_to_enemy: float = abs(player.position.distance_to(enemy.position))
	var direction_to_enemy: Vector2 = player.position.direction_to(enemy.position)
	var distance_to_enemy_blip: float = distance_to_enemy/radar_range * radar_circle_radius
	var vector_to_enemy: Vector2 = direction_to_enemy * clampf(distance_to_enemy_blip, 0.0, radar_circle_radius)
	var flicker_speed: float = 1.0 - clampf(distance_to_enemy/radar_range, 0.0, 1.0)
	var current_speed: float = flicker_speed * max_flicker_speed + min_flicker_speed
	flicker_time += delta * current_speed
	set_instance_shader_parameter("flicker_time", flicker_time)
	global_position = radar_center_pos + vector_to_enemy + parent.pivot_offset

func _kill_blip() -> void:
	queue_free()
