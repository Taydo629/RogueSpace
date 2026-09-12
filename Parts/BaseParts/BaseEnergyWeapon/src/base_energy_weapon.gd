class_name BaseEnergyWeapon extends BasePart

# Weapon related exports
var round_scene: PackedScene
var fire_rate : float
var weapon_damage: float
var round_speed: int
@onready var muzzle: Node2D = $Muzzle
@onready var fire_sound: AudioStreamPlayer2D = $FireSound
@onready var laser_beam_2d: RayCast2D = $LaserBeam2D
# Not used but could be used in future for configurable control
var activation_key: String
var gun_ready: bool = true
var timer: Timer
var laser_on: bool = false

var part:Part:
	set(value):
		sprite = value.image
		max_health = value.max_health
		health = value.current_health
		weapon_damage = value.damage
		round_speed = value.round_speed
		round_scene = value.round_scene
		fire_rate = value.fire_rate
		timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(_weapon_ready)
		timer.wait_time = fire_rate
		part = value

#func _physics_process(delta: float) -> void:
	#if laser_on:
		#pass
	#else:
		##laser_beam_2d.set_is_casting(false)
		#pass
#
#func set_is_casting(new_value: bool) -> void:
	#if is_casting == new_value:
		#return
	#is_casting = new_value
#
	##set_physics_process(is_casting)
#
	#if not laser_beam:
		#return
#
	#if is_casting:
		#var laser_start := Vector2.RIGHT * start_distance
		#laser_beam.points[0] = laser_start
		#laser_beam.points[1] = laser_start
		#appear()
	#else:
		#ray_cast_2d.target_position = Vector2.ZERO
		#disappear()
#
#func appear() -> void:
	#print("Laser on animation")
	#laser_beam.visible = true
	#if tween and tween.is_running():
		#tween.kill()
	#tween = create_tween()
	#tween.tween_property(laser_beam, "width", laser_beam.width, growth_time * 2.0).from(0.0)
#
#
#func disappear() -> void:
	#if tween and tween.is_running():
		#tween.kill()
	#tween = create_tween()
	#tween.tween_property(laser_beam, "width", 0.0, growth_time).from_current()
	#tween.tween_callback(laser_beam.hide)
#
#
#func set_color(new_color: Color) -> void:
	#color = new_color
	#if laser_beam == null:
		#return
	#laser_beam.modulate = new_color

func toggle_weapon(parent_node: RigidBody2D, toggle: bool) -> void:
	print("Firing Laser")
	if toggle:
		laser_beam_2d.set_is_casting(true)
	else:
		laser_beam_2d.set_is_casting(false)

func _weapon_ready() -> void:
	gun_ready = true
