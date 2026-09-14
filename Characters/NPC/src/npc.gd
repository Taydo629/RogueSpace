class_name npc extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var npc_input_component: NPC_input_component = $NPCInputComponent
@onready var detection_area: Area2D = $DetectionArea
@onready var collision_shape_2d: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var energy_component: EnergyComponent = $EnergyComponent
@onready var shield_component: ShieldComponent = $ShieldComponent

var ship_graph: Dictionary
		
var grid_dim: float = 5
var grid_size: float = 64
@export var detection_range: int = 1500
@export var wander_range: int = 4000

func _ready() -> void:
	collision_shape_2d.shape.radius = detection_range
	part_component.graph_changed.connect(reinitialise_components)
	part_component.ship_destroyed.connect(destroy_ship)
	npc_input_component.anchor_pos = global_position
	npc_input_component.detection_area = detection_area
	npc_input_component.wander_range = wander_range
	npc_input_component.fire_guns.connect(weapon_component.fire)
	npc_input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	npc_input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	npc_input_component.target_pos_changed.connect(movement_component.rotate_to)
	npc_input_component.init_input()
	create_ship()

func create_ship():
	mass = 0.001
	for key in ship_graph.keys():
		var node: Dictionary = ship_graph.get(key)
		var part: Part = node.part
		mass += part.weight
		var part_scene = part.scene.instantiate()
		node.instance = part_scene
		part_scene.part = part
		part_scene.parent = self
		var off_set: Vector2 = (grid_dim-1    )/2.0 * Vector2(grid_size,grid_size)
		part_scene.position = node.grid_pos * Vector2(grid_size,grid_size) - off_set
		part_component.add_child(part_scene)
		part_scene.attach(key)
	
	
	init_ship()

func init_ship() -> void:
	shield_component.energy_component = energy_component
	part_component.ship_graph = ship_graph
	reinitialise_components()

func reinitialise_components() -> void:
	print("Re-initialise components")
	#ship_graph = part_component.ship_graph
	movement_component.initalise_movement(ship_graph)
	weapon_component.initalise_weapons(ship_graph)

func destroy_ship() -> void:
	print("Destroying ship")
	for node in part_component.get_children():
		# Reparent to node above i.e. Level generator
		node.reparent(get_parent())
	print("All parts removed from ship")
	queue_free()
