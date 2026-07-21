extends RigidBody2D

@export var max_health: int = 100

var health: int
var colider: CollisionPolygon2D
var dict_key: String
var beam_active: bool = false
@onready var cpu_particles_2d: CPUParticles2D = $Polygon2D/CPUParticles2D
#part resource
var part = load("res://data/Parts/tractor_beam.tres")

const PART_COLIDER = preload("uid://cwrgd2ogtl6hd")

signal part_destroyed

func _ready() -> void:
	if get_parent().has_method("part_destroyed"):
		part_destroyed.connect(get_parent().part_destroyed)
	health = max_health

func _physics_process(delta: float) -> void:
	if beam_active:
		cpu_particles_2d.emitting = true
	else:
		cpu_particles_2d.emitting = false

func _collect_part(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if get_parent().is_in_group("player_ship"):
			Inventory.add_item(body.part)
			body.take_damage(100000)
	pass # Replace with function body.

func _attract_part(body: Node2D) -> void:
	pass # Replace with function body.

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
