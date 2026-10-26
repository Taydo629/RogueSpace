class_name ModifierBlock extends BasePart

# Modifier related exports
var grid_key_to_modify: Array[String]
var modifier_multiplier: int

@export var modifyier_directions: Array[Vector2i]

var part:Part:
	set(value):
		sprite = value.sprite
		max_health = value.max_health
		health = value.current_health
		# Initialize modifier attributes here
		part = value

func modify_parts(part_keys: Array[String]) -> void:
	if parent not in [npc, Player]:
		return
	var ship_graph: Dictionary = parent.ship_graph
	for key in part_keys:
		if key in ship_graph.keys():
			var node_to_mod: Dictionary = ship_graph.get(key)
			var part_to_mod: Part = node_to_mod.part
			if self not in part_to_mod.applied_modifiers:
				part_to_mod.applied_modifiers.append(self)
				part_to_mod.current_modifier *= modifier_multiplier
			
