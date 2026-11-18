class_name WeaponComponent extends Node

var weapons : Array[BasePart]
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
		if weapon.has_method("fire_weapon"):
			weapon.fire_weapon(parent)

func toggle_fire(toggle: bool) -> void:
	for weapon in weapons:
		if weapon.has_method("toggle_weapon"):
			if toggle:
				weapon.toggle_weapon(parent, true)
			else:
				weapon.toggle_weapon(parent, false)
