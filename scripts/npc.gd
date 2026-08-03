class_name npc extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var npc_input_component: NPC_input_component = $NPCInputComponent
@onready var detection_area: Area2D = $DetectionArea
@onready var collision_shape_2d: CollisionShape2D = $DetectionArea/CollisionShape2D

var ship_graph: Dictionary
var grid_dim: int
@export var detection_range: int = 1500
@export var wander_range: int = 4000

func _ready() -> void:
	collision_shape_2d.shape.radius = detection_range
	part_component.graph_changed.connect(reinitialise_components)
	npc_input_component.anchor_pos = global_position
	npc_input_component.detection_area = detection_area
	npc_input_component.wander_range = wander_range
	npc_input_component.fire_guns.connect(weapon_component.fire)
	npc_input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	npc_input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	npc_input_component.target_pos_changed.connect(movement_component.rotate_to)
	npc_input_component.init_input()
	init_ship()

func init_ship() -> void:
	print(mass)
	part_component.ship_graph = ship_graph
	part_component.grid_size = grid_dim
	part_component.initialise_ship()
	print(mass)

func reinitialise_components() -> void:
	print("Re-initialise components")
	ship_graph = part_component.ship_graph
	movement_component.initalise_movement(ship_graph)
	weapon_component.initalise_weapons(ship_graph)
