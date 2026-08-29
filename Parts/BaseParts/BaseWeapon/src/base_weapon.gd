class_name BaseWeapon extends BasePart

@export var part_health: int = 100

# Weapon related exports
var round_scene: PackedScene
var fire_rate : float
var weapon_damage: int
var round_speed: int
@onready var muzzle: Node2D = $Muzzle
@onready var fire_sound: AudioStreamPlayer2D = $FireSound

# Not used but could be used in future for configurable control
var activation_key: String
var gun_ready: bool = true
var timer: Timer

@onready var live_rounds: Node = $LiveRounds

func _ready() -> void:
	if part != null and part.part_type == part.PART_TYPE.WEAPON:
		max_health = part.max_health
		health = max_health
		timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(_weapon_ready)
		fire_rate = part.fire_rate
		timer.wait_time = fire_rate
		round_scene = part.round_scene
		weapon_damage = part.damage
		round_speed = part.round_speed

func fire_weapon(parent_node: RigidBody2D) -> void:
	if gun_ready:
		fire_sound.play()
		var projectile = round_scene.instantiate()
		# Initialise bullet with all required information
		projectile.global_position = muzzle.global_position
		projectile.rotation = parent_node.rotation
		projectile.damage = weapon_damage
		projectile.speed = round_speed
		projectile.initial_velocity = parent_node.linear_velocity
		projectile.parent = parent_node
		live_rounds.add_child(projectile)
		gun_ready = false
		timer.start()

func _weapon_ready() -> void:
	gun_ready = true
