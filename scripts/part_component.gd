class_name PartComponent extends Node

signal part_removed

func initialise_ship() -> void:
	var new_dict: Dictionary = {}
	for key in ShipInfo.ship_graph.keys():
		var graph_node = ShipInfo.ship_graph.get(key).duplicate()
		var new_part = graph_node.part.scene.instantiate()
		graph_node.instance = new_part
		new_dict.set(key, graph_node)
		new_part.rotation = graph_node.rotation
		new_part.scale = graph_node.scale
		var off_set: Vector2 = ShipInfo.current_grid_dim/2 * Vector2(64,64)
		new_part.position = graph_node.grid_pos * Vector2(64,64) - off_set
		add_child(new_part)
		new_part.attach(key)
	ShipInfo.ship_graph = new_dict

func part_destroyed(graph_key:String):
	#destruction_sound.play()
	var ship_graph = ShipInfo.ship_graph
	var destroyed_node = ship_graph.get(graph_key)
	if destroyed_node != null:
		for neighbor_key in destroyed_node.neighbors:
			var neighbor = ship_graph.get(neighbor_key)
			for key in neighbor.neighbors:
				if key == graph_key:
					neighbor.neighbors.erase(key)
		ship_graph.erase(graph_key)
		call_deferred("check_integrity",graph_key)

func find_core() -> String:
	var ship_graph = ShipInfo.ship_graph
	var core_key: String
	for key in ship_graph.keys():
		var node = ship_graph.get(key)
		if node.part.name == "core":
			core_key = key
	return core_key
	

func check_integrity(removed_key: String) -> void:
	var ship_graph = ShipInfo.ship_graph
	var has_detached = false
	var core_key = find_core()
	if core_key == "":
		print("Root node has been destroyed")
		for key in ship_graph.keys():
			# Currently when root is destroyed all remaining parts are detached
			# Infuture this could randomly destroy some parts when this happens
			var part = ship_graph.get(key)
			part.instance.detached()
			has_detached = true
		print("Emitting the part_removed Signal")
		part_removed.emit()
		return
	else:
		for key in ship_graph.keys():
			var part = ship_graph.get(key)
			if part.neighbors == []:
				print("part is not connected to any other parts.")
				#part.instance.reparent(get_parent())
				part.instance.detached()
				has_detached = true
		
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
					print("part is no longer connected to root.")
					#part.instance.reparent(get_parent())
					part.instance.detached()
					has_detached = true
		print("Emitting the part_removed Signal")
		part_removed.emit()
