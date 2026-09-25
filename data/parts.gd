class_name Part
extends Resource

enum PART_TYPE{STRUCTURAL, WEAPON, THRUSTER}
enum POSSIBLE_NEIGHBORS{UP, RIGHT, DOWN, LEFT, ALL}

@export var name: String
@export var scene: PackedScene
@export var image: Texture2D
@export var buy_price: int
@export var sell_price: int
@export var weight: int
@export var max_health: int:
	set(value):
		max_health = value
		current_health = max_health
@export var part_type: PART_TYPE
@export var possible_neighbors: Array[POSSIBLE_NEIGHBORS]
@export var thrust_force: int
# Kinetic weapon specific properties
@export var fire_rate: float
@export var damage: float
@export var round_speed: int
@export var round_scene: PackedScene
@export var ammo_cost: int
# Energy weapon specific properties
@export var dps: float
@export var energy_p_s: float
# This is to be updated when parts are moved to and from inventory
var current_health: int
