extends RigidBody2D

@export var thrust_force: int = 1
var thrust_direction: Vector2 = Vector2.UP
var activation_key: String
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@export var max_health: int = 100
var colider: CollisionPolygon2D
var health: int
var dict_key: String
#part resource
var part = load("res://data/Parts/thruster.tres")

const PART_COLIDER = preload("uid://1k6s26tooh6e")

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
		queue_free()
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
