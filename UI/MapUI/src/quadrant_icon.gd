class_name QuadrantIcon
extends TextureRect

var icon_texture: Texture2D:
	set(value):
		texture = value
		icon_texture = value
var quadrant: Quadrant
var is_hovered: bool = false
var is_selected: bool = false
@export var hover_grow: float = 1.2
@export var grow_time: float = 0.2

signal selected(QuadrantIcon)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and is_hovered:
		selected.emit(self)
		is_selected = true
		print("selected!")

func unselect_quadrant() -> bool:
	if not is_hovered:
		is_selected = false
		_on_unhover()
		return true
	else:
		return false

func _on_mouse_entered() -> void:
	is_hovered = true
	_on_hover()

func _on_mouse_exited() -> void:
	is_hovered = false
	if not is_selected:
		_on_unhover()

func _on_hover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(hover_grow,hover_grow), grow_time)

func _on_unhover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), grow_time)
