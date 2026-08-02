class_name Player extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var input_component: InputComponent = $InputComponent
@onready var player_camera: Camera2D = $PlayerCamera

func _ready() -> void:
	ShipInfo.ship_updated.connect(init_ship)
	part_component.graph_changed.connect(reinitialise_components)
	input_component.fire_guns.connect(weapon_component.fire)
	input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	input_component.mouse_pos_changed.connect(movement_component.rotate_to)

func init_ship(ship_graph, grid_dim) -> void:
	part_component.ship_graph = ship_graph
	part_component.grid_size = grid_dim
	player_camera.enabled = true
	part_component.initialise_ship()

func reinitialise_components() -> void:
	print("Re-initialise components")
	ShipInfo.update_ship(part_component.ship_graph)
	movement_component.initalise_movement(ShipInfo.ship_graph)
	weapon_component.initalise_weapons(ShipInfo.ship_graph)
