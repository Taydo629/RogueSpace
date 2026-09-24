class_name QuadrantIcon
extends TextureRect

var icon_texture: Texture2D:
	set(value):
		texture = value
		icon_texture = value
var quadrant: Quadrant
var reachable: bool = true:
	set(value):
		reachable = value
		set_availability()
		
var is_hovered: bool = false
var is_selected: bool = false
@export var hover_grow: float = 1.2
@export var grow_time: float = 0.2

signal selected(QuadrantIcon)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and is_hovered and reachable:
		selected.emit(self)
		is_selected = true
		set_instance_shader_parameter("selected", true)
		print("selected!")

func set_availability() -> void:
	set_physics_process(reachable)
	
	if reachable == false:
		set_instance_shader_parameter("reachable", false)
	else:
		set_instance_shader_parameter("reachable", true)

func highlighted() -> void:
	set_instance_shader_parameter("highlighted", true)

func unhighlighted() -> void:
	set_instance_shader_parameter("highlighted", false)

func unselect_quadrant() -> bool:
	if not is_hovered and reachable:
		is_selected = false
		set_instance_shader_parameter("selected", false)
		_on_unhover()
		return true
	else:
		return false

func _on_mouse_entered() -> void:
	if reachable:
		is_hovered = true
		_on_hover()

func _on_mouse_exited() -> void:
	is_hovered = false
	if not is_selected and reachable:
		_on_unhover()

func _on_hover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(hover_grow,hover_grow), grow_time)

func _on_unhover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), grow_time)
