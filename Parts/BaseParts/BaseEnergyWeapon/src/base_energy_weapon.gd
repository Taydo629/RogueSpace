class_name BaseEnergyWeapon extends BasePart

# Weapon related exports
var round_scene: PackedScene
var fire_rate : float
var weapon_damage: float
var round_speed: int
@onready var muzzle: Node2D = $Muzzle
@onready var fire_sound: AudioStreamPlayer2D = $FireSound
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var laser_beam: Line2D = $RayCast2D/LaserBeam
var cast_speed := 7000.0
var max_length := 1400.0
var start_distance := 40.0
var growth_time := 0.1
var color := Color.WHITE: set = set_color
var is_casting := false: set = set_is_casting
var tween: Tween = null
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

func _physics_process(delta: float) -> void:
	ray_cast_2d.target_position.x = move_toward(
		ray_cast_2d.target_position.x,
		max_length,
		cast_speed * delta
	)

	var laser_end_position := ray_cast_2d.target_position
	ray_cast_2d.force_raycast_update()

	if ray_cast_2d.is_colliding():
		laser_end_position = to_local(ray_cast_2d.get_collision_point())

	laser_beam.points[1] = laser_end_position

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value

	set_physics_process(is_casting)

	if not laser_beam:
		return

	if is_casting:
		var laser_start := Vector2.RIGHT * start_distance
		laser_beam.points[0] = laser_start
		laser_beam.points[1] = laser_start
		appear()
	else:
		ray_cast_2d.target_position = Vector2.ZERO
		disappear()

func appear() -> void:
	laser_beam.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(laser_beam, "width", laser_beam.line_width, growth_time * 2.0).from(0.0)


func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(laser_beam, "width", 0.0, growth_time).from_current()
	tween.tween_callback(laser_beam.hide)


func set_color(new_color: Color) -> void:
	color = new_color
	if laser_beam == null:
		return
	laser_beam.modulate = new_color

func fire_weapon(parent_node: RigidBody2D) -> void:
	print("Firing Laser")
	if is_casting:
		fire_sound.play()
	else:
		is_casting = true
		#var projectile = round_scene.instantiate()
		## Initialise bullet with all required information
		#projectile.global_position = muzzle.global_position
		#projectile.rotation = fmod(parent_node.rotation + rotation,2.0*PI)
		#projectile.damage = weapon_damage
		#projectile.speed = round_speed
		#projectile.initial_velocity = parent_node.linear_velocity
		#projectile.parent = parent_node
		#live_rounds.add_child(projectile)
		#gun_ready = false
		#timer.start()

func _weapon_ready() -> void:
	gun_ready = true
