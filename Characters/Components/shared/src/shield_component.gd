class_name ShieldComponent extends Node2D

@export var max_shield_health: float = 500.0
@export var shield_recharge_time: float = 10.0

@onready var shield_area: Area2D = $ShieldArea
@onready var shield_sprite: Sprite2D = $Shield_sprite

var health: float
var parent: RigidBody2D
var timer: Timer

func _ready() -> void:
	parent = get_parent()
	health = max_shield_health
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = shield_recharge_time
	timer.timeout.connect(recharge_shield)

func take_damage(damage: int, pos: Vector2) -> void:
	var new_health = health - damage
	#hit_sound.play()
	var vector_to_projectile: Vector2 = pos - global_position
	var vector_to_forward: Vector2 = Vector2.UP.rotated(rotation)
	var angle: float = vector_to_forward.angle_to(vector_to_projectile)
	print(angle)
	shield_sprite.material.set_shader_parameter("highlight_angle", angle)
	if new_health <= 0:
		shield_area.monitorable = false
	else:
		health = new_health

func recharge_shield() -> void:
	shield_area.monitorable = true
	health = max_shield_health
