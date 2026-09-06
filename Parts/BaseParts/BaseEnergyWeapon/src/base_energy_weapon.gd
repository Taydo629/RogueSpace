class_name BaseEnergyWeapon extends BasePart

# Weapon related exports
var round_scene: PackedScene
var fire_rate : float
var weapon_damage: float
var round_speed: int
@onready var muzzle: Node2D = $Muzzle
@onready var fire_sound: AudioStreamPlayer2D = $FireSound

# Not used but could be used in future for configurable control
var activation_key: String
var gun_ready: bool = true
var timer: Timer

@onready var live_rounds: Node = $LiveRounds

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

func fire_weapon(parent_node: RigidBody2D) -> void:
	if gun_ready:
		fire_sound.play()
		var projectile = round_scene.instantiate()
		# Initialise bullet with all required information
		projectile.global_position = muzzle.global_position
		projectile.rotation = fmod(parent_node.rotation + rotation,2.0*PI)
		projectile.damage = weapon_damage
		projectile.speed = round_speed
		projectile.initial_velocity = parent_node.linear_velocity
		projectile.parent = parent_node
		live_rounds.add_child(projectile)
		gun_ready = false
		timer.start()

func _weapon_ready() -> void:
	gun_ready = true
