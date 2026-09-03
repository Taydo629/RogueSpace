class_name NPCGraph
extends Resource

@export var graph: Dictionary

func get_dictionary() -> Dictionary:
	# This is important so that the graph resource isnt modified by partcomponent.
	return(graph.duplicate(true))
