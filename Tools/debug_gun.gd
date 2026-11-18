extends Node2D
@onready var player: Player = $".."
@export var fire_rate : float = 0.2
const BULLET = preload("uid://sufhro00r1n7")
var mouse_pos: Vector2
var timer: Timer
var gun_ready: bool = true

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = fire_rate

func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		fire(player.get_global_mouse_position())

func fire(origin: Vector2) -> void:
	if gun_ready:
		var bullet_inst = BULLET.instantiate()
		bullet_inst.position = origin
		add_child(bullet_inst)
		timer.start()
		gun_ready = false

func _on_timer_timeout() -> void:
	# Cooldown ended gun is ready again
	gun_ready = true
