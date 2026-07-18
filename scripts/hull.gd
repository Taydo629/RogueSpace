extends Node2D

@export var max_health: int = 100

var health: int

func _ready() -> void:
	health = max_health

func take_damage(damage: int) -> void:
	var new_health = health - damage
	
	if new_health <= 0:
		queue_free()
	else:
		health = new_health
