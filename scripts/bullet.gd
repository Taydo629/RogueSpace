extends StaticBody2D

@export var speed: int = 500
@export var damage: int = 20

func _physics_process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * speed * delta

func _on_collision_polygon_2d_area_entered(area: Area2D) -> void:
	# Check if the colision is from the same parent.
	if get_parent().get_parent() != area.get_parent().get_parent():
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
			queue_free()
