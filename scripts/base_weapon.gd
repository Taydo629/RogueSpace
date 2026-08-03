class_name BaseWeapon extends BasePart

@export var part_health: int = 100

# Weapon related exports
@export var round_scene: PackedScene
@export var fire_rate : float = 0.2
@export var weapon_damage: int = 10
@export var round_speed: int = 750
@onready var muzzle: Node2D = $Muzzle
@onready var fire_sound: AudioStreamPlayer2D = $FireSound

# Not used but could be used in future for configurable control
var activation_key: String
var gun_ready: bool = true
var timer: Timer

@onready var live_rounds: Node = $LiveRounds

func _ready() -> void:
	max_health = part_health
	health = max_health
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_weapon_ready)
	timer.wait_time = fire_rate

func fire_weapon(parent_node: RigidBody2D) -> void:
	if gun_ready:
		fire_sound.play()
		var round = round_scene.instantiate()
		# Initialise bullet with all required information
		round.global_position = muzzle.global_position
		round.rotation = parent_node.rotation
		round.damage = weapon_damage
		round.speed = round_speed
		round.initial_velocity = parent_node.linear_velocity
		round.parent = parent_node
		live_rounds.add_child(round)
		gun_ready = false
		timer.start()

func _weapon_ready() -> void:
	gun_ready = true
