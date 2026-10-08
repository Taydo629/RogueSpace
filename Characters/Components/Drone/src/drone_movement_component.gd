class_name DroneMovementComponent extends Node

enum STATE{PATROL, SEARCH, ATTACK}

var current_state: STATE = STATE.PATROL
var player: Player
var target_position: Vector2
var patrol_position: Vector2

@export var patrol_radius: float
@export var thrust_force: float
@export var view_range: float
@export var damage_per_shot: float

func _physics_process(delta: float) -> void:
	if current_state == STATE.PATROL:
		_patrol()
	elif current_state == STATE.SEARCH:
		_search()
	else:
		_attack()

func _patrol() -> void:
	if patrol_position != null:
		pass

func _search() -> void:
	pass

func _attack() -> void:
	pass
