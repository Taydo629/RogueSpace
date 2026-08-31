extends StaticBody2D

@export var lifetime: int = 5
var speed: int = 500
var damage: int = 20
var timer: Timer
var parent: RigidBody2D
var initial_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(cull)
	timer.wait_time = lifetime
	timer.start()

func _physics_process(delta: float) -> void:
	position += (Vector2.UP.rotated(rotation) * speed + initial_velocity) * delta

func _on_collision_polygon_2d_area_entered(area: Area2D) -> void:
	# Check if the colision is from the same parent.
	if "parent" in area.get_parent():
		if parent != area.get_parent().parent:
			if area.get_parent().has_method("take_damage") and area.is_in_group("hurt_box"):
				area.get_parent().take_damage(damage)
				queue_free()

func cull() -> void:
	queue_free()
	
