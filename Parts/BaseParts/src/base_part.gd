class_name BasePart extends RigidBody2D

@onready var hit_sound: AudioStreamPlayer2D = $Hit_sound
@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collider: CollisionShape2D = $Collider
@onready var smoke_particles: CPUParticles2D = $SmokeParticles
const EXPLOSION_PARTICLE = preload("res://Effects/explosion_particle.tscn")

var max_health: int:
	set(value):
		max_health = value
		health = max_health
var health: int
var dict_key: String
var is_detached: bool = false
var parent: RigidBody2D
var sprite: Texture2D

@export var damage_camera_shake_mag: float = 0.1
@export var destruction_camera_shake_mag: float = 0.25
@export var destruction_impulse_magnitude: float = 750.0

signal part_destroyed
signal part_detached

func _ready() -> void:
	if sprite != null:
		polygon_2d.set_texture(sprite)
		polygon_2d.texture_offset = Vector2(32,32)

func take_damage(damage: int) -> void:
	var new_health = health - damage
	hit_sound.play()
	
	if new_health <= 0:
		CameraManager.apply_camera_shake(destruction_camera_shake_mag)
		part_destroyed.emit(dict_key)
		if parent != null:
			var explosion_effect:CPUParticles2D = EXPLOSION_PARTICLE.instantiate()
			explosion_effect.finished.connect(explosion_effect.queue_free)
			parent.add_child(explosion_effect)
			explosion_effect.emitting = true
		collider.queue_free()
		queue_free()
	else:
		CameraManager.apply_camera_shake(damage_camera_shake_mag)
		health = new_health
		var frac_hp = float(new_health)/float(max_health)
		var part_color: Color = polygon_2d.color
		if frac_hp < 0.5 and frac_hp >= 0.25:
			smoke_particles.emitting = true
			part_color = Color(0.89,0.4,0,1)
		elif frac_hp < 0.25:
			part_color = Color(0.53, 0.03, 0.0, 1.0)
		polygon_2d.color = part_color

func heal(healed_health:int) -> void:
	var new_health = clamp(health + healed_health, 0, max_health)
	health = new_health
	var frac_hp = float(health)/float(max_health)
	var part_color: Color = Color(1,1,1,1)
	if frac_hp >= 0.5:
		smoke_particles.emitting = false
	elif frac_hp < 0.5 and frac_hp >= 0.25:
		smoke_particles.emitting = true
		part_color = Color(0.89,0.4,0,1)
	else:
		smoke_particles.emitting = true
		part_color = Color(0.53, 0.03, 0.0, 1.0)
	polygon_2d.color = part_color

## Function used when attaching a part to a ship
##
## The function returns the collision shape to be used
func attach(new_key: String) -> void:
	#var new_collider: CollisionShape2D = collider.duplicate()
	collider.reparent(parent)
	dict_key = new_key
	freeze = true
	if not part_destroyed.is_connected(get_parent().part_destroyed):
		part_destroyed.connect(get_parent().part_destroyed)
	#return(new_collider)

func detached() -> void:
	collider.reparent(self)
	collider.disabled = false
	is_detached = true
	part_detached.emit()
	freeze = false
	var random_impulse: Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1))
	apply_central_impulse(random_impulse.normalized() * destruction_impulse_magnitude)
