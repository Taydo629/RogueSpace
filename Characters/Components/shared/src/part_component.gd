class_name PartComponent extends Node2D

@export var ship_destroyed_magnitude: float = 1.0

var parent: RigidBody2D
var grid_size: int
var ship_graph: Dictionary

signal graph_changed
signal ship_destroyed

func _ready() -> void:
	parent = get_parent()

func part_destroyed(graph_key:String):
	if graph_key in ship_graph:
		#destruction_sound.play()
		var destroyed_node = ship_graph.get(graph_key)
		# remove destroyed nodes weight from ship
		parent.mass -= destroyed_node.part.weight
		if destroyed_node != null:
			for neighbor_key in destroyed_node.neighbors:
				var neighbor = ship_graph.get(neighbor_key)
				if neighbor != null:
					for key in neighbor.neighbors:
						if key == graph_key:
							neighbor.neighbors.erase(key)
			ship_graph.erase(graph_key)
			if ship_graph.size() == 0:
				ship_destroyed.emit()
			else:
				check_integrity(graph_key)

func find_core() -> String:
	var core_key: String
	for key in ship_graph.keys():
		var node = ship_graph.get(key)
		if node.part.name == "core":
			core_key = key
	return core_key

func check_integrity(removed_key: String) -> void:
	var has_detached = false
	var core_key = find_core()
	if core_key == "":
		print("Root node has been destroyed")
		for key in ship_graph.keys():
			# Currently when root is destroyed all remaining parts are detached
			# Infuture this could randomly destroy some parts when this happens
			var part = ship_graph.get(key)
			# remove weight from ship is not needed as ship as a whole is now destroyed!
			part.instance.call_deferred("detached")
			has_detached = true
		CameraManager.apply_camera_shake(ship_destroyed_magnitude)
		ship_graph.clear()
		print("Emitting the part_removed Signal")
		graph_changed.emit()
		ship_destroyed.emit()
		return
	elif ship_graph.size() == 1:
		print("Ship has only core left!")
		for key in ship_graph.keys():
			# Currently when root is destroyed all remaining parts are detached
			# Infuture this could randomly destroy some parts when this happens
			var part = ship_graph.get(key)
			# remove weight from ship is not needed as ship as a whole is now destroyed!
			part.instance.call_deferred("detached")
		ship_graph.clear()
		graph_changed.emit()
		ship_destroyed.emit()
		return
	else:
		for key in ship_graph.keys():
			var part = ship_graph.get(key)
			if part.neighbors == []:
				# remove destroyed nodes weight from ship
				parent.mass -= part.part.weight
				ship_graph.erase(key)
				print("part is not connected to any other parts.")
				part.instance.call_deferred("detached")
				has_detached = true
				if ship_graph.size() == 0:
					ship_destroyed.emit()
		
		# Following is to search if a colection of parts have been severed
		# from the root node.
		if not has_detached:
			var nodes_to_visit = []
			var visited_nodes = []
			var root_node = ship_graph.get(core_key)
			nodes_to_visit.append_array(root_node.neighbors)
			nodes_to_visit.erase(removed_key)
			var search_complete = false
			while not search_complete:
				if nodes_to_visit == []:
					search_complete = true
				else:
					var current_node_key = nodes_to_visit[0]
					visited_nodes.append(current_node_key)
					if current_node_key in ship_graph.keys():
						nodes_to_visit.append_array(ship_graph.get(current_node_key).neighbors)
					nodes_to_visit.erase(current_node_key)
					nodes_to_visit.erase(removed_key)
					for node in visited_nodes:
						nodes_to_visit.erase(node)
			# Search for nodes which were not visited when traversing from root node
			# Deatch these nodes
			for key in ship_graph.keys():
				if key not in visited_nodes:
					var part = ship_graph.get(key)
					# remove destroyed nodes weight from ship
					parent.mass -= part.part.weight
					ship_graph.erase(key)
					print("part is no longer connected to root.")
					part.instance.call_deferred("detached")
					has_detached = true
					if ship_graph.size() == 0:
						ship_destroyed.emit()
		print("Emitting the part_removed Signal")
		graph_changed.emit()
