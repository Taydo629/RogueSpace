extends StaticBody2D

@export var speed: int = 500
@export var damage: int = 20
@export var lifetime: int = 5
var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(cull)
	timer.wait_time = lifetime
	timer.start()

func _physics_process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * speed * delta

func _on_collision_polygon_2d_area_entered(area: Area2D) -> void:
	# Check if the colision is from the same parent.
	if get_parent().get_parent() != area.get_parent().get_parent():
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
			queue_free()

func cull() -> void:
	queue_free()
	
