class_name Player extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var input_component: InputComponent = $InputComponent
@onready var player_camera: Camera2D = $PlayerCamera


func _ready() -> void:
	ShipInfo.ship_updated.connect(init_ship)

func init_ship() -> void:
	player_camera.enabled = true
	part_component.initialise_ship()
