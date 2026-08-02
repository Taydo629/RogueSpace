class_name npc extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var npc_input_component: NPC_input_component = $NPCInputComponent

var ship_graph: Dictionary
var grid_dim: int

func _ready() -> void:
	part_component.graph_changed.connect(reinitialise_components)
	npc_input_component.fire_guns.connect(weapon_component.fire)
	npc_input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	npc_input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	npc_input_component.target_pos_changed.connect(movement_component.rotate_to)
	init_ship()

func init_ship() -> void:
	part_component.ship_graph = ship_graph
	part_component.grid_size = grid_dim
	part_component.initialise_ship()

func reinitialise_components() -> void:
	print("Re-initialise components")
	ship_graph = part_component.ship_graph
	movement_component.initalise_movement(ship_graph)
	weapon_component.initalise_weapons(ship_graph)
