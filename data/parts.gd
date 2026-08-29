class_name Part
extends Resource

enum PART_TYPE{STRUCTURAL, WEAPON, THRUSTER}

@export var name: String
@export var scene: PackedScene
@export var image: Texture2D
@export var buy_price: int
@export var sell_price: int
@export var weight: int
@export var max_health: int
@export var part_type: PART_TYPE
@export var thrust_force: int
@export var fire_rate: float
@export var damage: float
@export var round_speed: int
@export var round_scene: PackedScene
