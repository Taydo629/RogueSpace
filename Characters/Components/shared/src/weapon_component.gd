class_name WeaponComponent extends Node

var weapons : Array[BaseWeapon]
var parent: RigidBody2D

func _ready() -> void:
	parent = get_parent()

func initalise_weapons(ship_graph: Dictionary) -> void:
	weapons = []
	for node in ship_graph.values():
		if node.instance.is_in_group("weapon"):
			weapons.append(node.instance)

func fire() -> void:
	for weapon in weapons:
		weapon.fire_weapon(parent)
