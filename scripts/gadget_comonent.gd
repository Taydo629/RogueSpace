class_name GadgetComponent extends Node

var gadgets : Array[BasePart]
var parent: RigidBody2D

func _ready() -> void:
	parent = get_parent()

func initalise_weapons(ship_graph: Dictionary) -> void:
	gadgets = []
	for node in ship_graph.values():
		if node.instance.is_in_group("gadget"):
			gadgets.append(node.instance)

func fire() -> void:
	for weapon in weapons:
		weapon.fire_weapon(parent)
