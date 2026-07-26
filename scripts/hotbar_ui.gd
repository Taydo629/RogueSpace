extends TextureRect

@export var part: Part
@onready var label: Label = $Label

func _ready() -> void:
	if part != null:
		texture = part.image

func get_part() -> Part:
	return part

func update_count(count: int) -> void:
	label.text = str(count)
