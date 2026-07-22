extends RigidBody2D

@export var max_health: int = 300

var health: int
var colider: CollisionShape2D
var dict_key: String

const PART_COLIDER = preload("uid://d0dggj0ghuve3")
#part resource
var part = load("res://data/Parts/core.tres")

signal part_destroyed

func _ready() -> void:
	if get_parent().has_method("part_destroyed"):
		part_destroyed.connect(get_parent().part_destroyed)
	health = max_health

func take_damage(damage: int) -> void:
	var new_health = health - damage
	
	if new_health <= 0:
		part_destroyed.emit(dict_key)
		if colider != null:
			colider.queue_free()
		colider = null
		call_deferred("queue_free")
	else:
		health = new_health

func detached() -> void:
	if colider != null:
		colider.queue_free()
		colider = null
	var local_colider = PART_COLIDER.instantiate()
	add_child(local_colider)
	local_colider.global_position = global_position
	freeze = false
	
