extends TextureRect

@export var part: Part

func _ready() -> void:
	if part != null:
		texture = part.image

func get_part() -> Part:
	return part
