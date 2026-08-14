extends Node

var ship_graph: Dictionary = {}
var current_grid_dim: int

signal ship_updated

func initialise_ship(new_graph: Dictionary, dim: int) -> void:
	ship_graph = new_graph
	current_grid_dim = dim
	ship_updated.emit(ship_graph,current_grid_dim)

func update_ship(new_graph: Dictionary) -> void:
	ship_graph = new_graph
