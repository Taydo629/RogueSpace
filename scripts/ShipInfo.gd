extends Node

var ship_graph: Dictionary = {}
var current_grid_dim: int

signal ship_updated

func update_ship(new_graph: Dictionary, dim: int):
	ship_graph = new_graph
	current_grid_dim = dim
	ship_updated.emit()
