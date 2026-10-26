class_name Part
extends Resource

enum PART_TYPE{STRUCTURAL, KINETIC_WEAPON, ENERGY_WEAPON, THRUSTER}
enum POSSIBLE_NEIGHBORS{UP, RIGHT, DOWN, LEFT, ALL}


@export var name: String
@export var display_name: String
@export_multiline var part_description: String
@export var scene: PackedScene
@export var part_type: PART_TYPE
@export var possible_neighbors: Array[POSSIBLE_NEIGHBORS]
@export var round_scene: PackedScene
	
# Base stats for a part
@export var base_buy_price: int
@export var base_sell_price: int
@export var base_weight: int
@export var base_max_health: int
@export var base_thrust_force: int
# Kinetic weapon specific properties
@export var base_fire_rate: float
@export var base_damage: float
@export var base_round_speed: int
@export var base_ammo_cost: int
# Energy weapon specific properties
@export var base_dps: float
@export var base_energy_p_s: float

@export var level_dict: Dictionary[int, PartModifier]:
	set(value):
		level_dict = value
		_init_properties()

# Current sprite for part
var sprite: Texture2D

# Current level for part
var level: int = 1:
	set(value):
		if value in level_dict.keys():
			level = value
			_init_properties()
# Actual stats for a part
var buy_price: int
var sell_price: int
var weight: int
var max_health: int:
	set(value):
		max_health = value
		current_health = max_health
var thrust_force: int
# Kinetic weapon specific properties
var fire_rate: float
var damage: float
var round_speed: int
var ammo_cost: int
# Energy weapon specific properties
var dps: float
var energy_p_s: float

# This is to be updated when parts are moved to and from inventory
var current_health: int

var external_modifier: Array[ModifierBlock]
var current_external_multiplier: int = 0

func _init_properties() -> void:
	var current_modifiers: PartModifier = level_dict.get(level)
	sprite = current_modifiers.sprite
	buy_price = int(base_buy_price * current_modifiers.buy_price_modifier)
	sell_price = int(base_sell_price * current_modifiers.sell_price_modifier)
	weight = int(base_weight * current_modifiers.weight_modifier)
	max_health = int(base_max_health * current_modifiers.max_health_modifier)
	thrust_force = int(base_thrust_force * current_modifiers.thrust_force_modifier)
	fire_rate = base_fire_rate * current_modifiers.fire_rate_modifier
	damage = base_damage * current_modifiers.damage_modifier
	round_speed = int(base_round_speed * current_modifiers.round_speed_modifier)
	ammo_cost = int(base_ammo_cost * current_modifiers.ammo_cost_modifier)
	dps = base_dps * current_modifiers.dps_modifier
	energy_p_s = base_energy_p_s * current_modifiers.energy_p_s_modifier
