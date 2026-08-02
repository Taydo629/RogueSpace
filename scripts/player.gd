class_name Player extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var input_component: InputComponent = $InputComponent
@onready var player_camera: Camera2D = $PlayerCamera

func _ready() -> void:
	ShipInfo.ship_updated.connect(init_ship)
	part_component.part_removed.connect(reinitialise_components)
	#input_component.fire_guns.connect(fire)
	input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	input_component.mouse_pos_changed.connect(movement_component.rotate_to)

func init_ship() -> void:
	player_camera.enabled = true
	part_component.initialise_ship()
	movement_component.initalise_movement()

func reinitialise_components() -> void:
	print("Re-initialise components")
	movement_component.initalise_movement()
