class_name Quadrant
extends Resource

enum TYPE {COMBAT, MERCAHNT, SHIPYARD, NEUTRAL, BOSS}
const COMBAT_PROB: int = 2
const MERCAHNT_PROB: int = 1
const SHIPYARD_PROB: int = 1
const NEUTRAL_PROB: int = 3
const TOTAL_WEIGHT: int = 10

@export var type: TYPE
@export var position: Vector2
@export var next_quadrant: Array[Quadrant]
@export var reachable: bool = true

func _to_string() -> String:
	return str(TYPE.keys()[type])

func set_random_type() -> void:
	var possible_types: Array[TYPE]
	for i in COMBAT_PROB:
		possible_types.append(TYPE.COMBAT)
	for i in MERCAHNT_PROB:
		possible_types.append(TYPE.MERCAHNT)
	for i in SHIPYARD_PROB:
		possible_types.append(TYPE.SHIPYARD)
	for i in NEUTRAL_PROB:
		possible_types.append(TYPE.NEUTRAL)
	type = possible_types.pick_random()
