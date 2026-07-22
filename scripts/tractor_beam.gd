extends RigidBody2D

@export var max_health: int = 100
@export var beam_strength: int = 500

var health: int
var colider: CollisionPolygon2D
var dict_key: String
var beam_active: bool = false
var parts_in_beam: Array = []
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
		for part in parts_in_beam:
			var vector = global_position - part.global_position
			part.constant_force = vector.normalized()*beam_strength
	else:
		cpu_particles_2d.emitting = false

func _collect_part(body: Node2D) -> void:
	if body.has_method("take_damage") and beam_active:
		if get_parent().is_in_group("player_ship"):
			Inventory.add_item(body.part)
			body.take_damage(100000)
	pass # Replace with function body.

func _part_entered_beam(body: Node2D) -> void:
	if body.has_method("take_damage") and beam_active:
		if get_parent().is_in_group("player_ship"):
			parts_in_beam.append(body)

func _part_left_beam(body: Node2D) -> void:
	if body.has_method("take_damage") and beam_active:
		if get_parent().is_in_group("player_ship"):
			body.constant_force = Vector2.ZERO
			parts_in_beam.erase(body)

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
