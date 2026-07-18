extends StaticBody2D

@export var speed: int = 100

func _physics_process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * speed * delta
