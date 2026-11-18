extends BasePart

var activation_key: String

var part:Part:
	set(value):
		sprite = value.sprite
		max_health = value.max_health
		health = value.current_health
		part = value
#@export var part_health: int = 100
#
#func _ready() -> void:
	#max_health = part_health
	#health = max_health
