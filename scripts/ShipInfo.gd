extends Node

var ship_graph: Dictionary = {}

signal ship_updated

func update_ship(new_graph: Dictionary):
	ship_graph = new_graph
	ship_updated.emit()
