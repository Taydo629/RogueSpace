class_name ShieldComponent extends Node2D

#@export var max_shield_health: float = 500.0
@export var shield_recharge_time: float = 5.0
@export var shield_animation_time: float = 0.5
@export var damage_to_energy_ratio: float = 2

@onready var shield_area: Area2D = $ShieldArea
@onready var collision_shape_2d: CollisionShape2D = $ShieldArea/CollisionShape2D
@onready var shield_sprite: Sprite2D = $Shield_sprite

var parent: RigidBody2D
var timer: Timer
var shield_active: bool = true
var energy_component: EnergyComponent

func _ready() -> void:
	parent = get_parent()
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = shield_recharge_time
	timer.timeout.connect(recharge_shield)

func take_damage(damage: int) -> void:
	var current_shield_energy: float = energy_component.energy_pips.get(energy_component.ENERGY_ROUTES.SHIELDS).get("current_energy")
	var max_shield_energy: float = energy_component.energy_pips.get(energy_component.ENERGY_ROUTES.SHIELDS).get("max_energy")
	#var new_energy = current_shield_energy - damage * damage_to_energy_ratio
	if energy_component.use_energy(damage * damage_to_energy_ratio, energy_component.ENERGY_ROUTES.SHIELDS):
		var frac_energy: float = current_shield_energy / max_shield_energy
		shield_sprite.material.set_shader_parameter("damage_frac", frac_energy)
	else:
		var tween: Tween = create_tween()
		tween.tween_property(shield_sprite.material, "shader_parameter/dissolve_progress", 1.0, shield_animation_time)
		tween.finished.connect(shield_down)

func shield_down() -> void:
	shield_active = false
	shield_sprite.visible = false
	timer.start()

func recharge_shield() -> void:
	shield_active = true
	shield_sprite.visible = true
	shield_sprite.material.set_shader_parameter("damage_frac", 1.0)
	var tween: Tween = create_tween()
	tween.tween_property(shield_sprite.material, "shader_parameter/dissolve_progress", 0.0, shield_animation_time)
