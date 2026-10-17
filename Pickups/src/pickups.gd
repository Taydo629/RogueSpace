class_name Pickups extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var pickups: Pickups = $"."
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

enum PICKUP_TYPE{CREDIT, AMMO, EXPLOSIVE}

@export var credit_sprite: Texture2D
@export var ammo_sprite: Texture2D
@export var explosive_sprite: Texture2D
@export var tracking_speed: float = 100

var amount_in_pickup: int

var pick_up_type: PICKUP_TYPE:
	set(value):
		pick_up_type = value
		if pick_up_type == PICKUP_TYPE.CREDIT:
			sprite.texture = credit_sprite
		elif pick_up_type == PICKUP_TYPE.AMMO:
			sprite.texture = ammo_sprite
		elif pick_up_type == PICKUP_TYPE.EXPLOSIVE:
			sprite.texture = explosive_sprite

var player: Player:
	set(value):
		player = value

func _ready() -> void:
	timer.timeout.connect(_make_available_for_pickup)
	timer.start()
	set_physics_process(false)

func _make_available_for_pickup() -> void:
	collision_shape_2d.disabled = false

func pick_up() -> void:
	if pick_up_type == PICKUP_TYPE.CREDIT:
		Inventory.deposit_to_wallet(amount_in_pickup)
	elif pick_up_type == PICKUP_TYPE.AMMO:
		Inventory.add_ammo(amount_in_pickup)
	elif pick_up_type == PICKUP_TYPE.EXPLOSIVE:
		Inventory.add_explosive(amount_in_pickup)
	queue_free()

func _physics_process(_delta: float) -> void:
	if player != null:
		var vec_to_player: Vector2 = (player.position - position).normalized()
		constant_force = vec_to_player * tracking_speed

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		set_physics_process(true)
