class_name ShipObject extends RigidBody2D

@onready var thrust_component: ThrustComponent = $ThrustComponent
@onready var gyro_component: GyroComponent = $GyroComponent
@onready var gun_component: GunComponent = $GunComponent
@onready var tractorbeam_component: TractorbeamComponent = $TractorbeamComponent

var x_min = -160
var y_min = -160

func _ready() -> void:
	pass

func init_ship():
	var ship_graph = ShipInfo.ship_graph
	for key in ship_graph.keys():
		var node = ship_graph.get(key)
		var part = node.part.scene.instantiate()
		var colider = node.part.collider.instantiate()
		var x = x_min + node.grid_pos.x * 64
		var y = y_min + node.grid_pos.y * 64
		#node.part = part
		node.colider = colider
		part.position = Vector2(x,y)
		colider.position = Vector2(x,y)
		part.rotation_degrees = node.rotation
		colider.rotation_degrees = node.rotation
		if node.mirrored:
			part.scale = Vector2(-1,1)
			colider.scale = Vector2(-1,1)
		add_child(part)
		add_child(colider)
		part.colider = colider
		part.dict_key = key
				
	init_components()

func init_components() -> void:
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_AUTO
	if gyro_component:
		gyro_component.active_ship = self
	thrust_component.update_thrusters()
	gun_component.update_guns()
	tractorbeam_component.update_tractorbeam()

func part_destroyed(graph_key:String):
	var ship_graph = ShipInfo.ship_graph
	var destroyed_node = ship_graph.get(graph_key)
	for neighbor_key in destroyed_node.neighbors:
		var neighbor = ship_graph.get(neighbor_key)
		for key in neighbor.neighbors:
			if key == graph_key:
				neighbor.neighbors.erase(key)
	ship_graph.erase(graph_key)
	call_deferred("check_integrity",graph_key)

func check_integrity(removed_key: String) -> void:
	var ship_graph = ShipInfo.ship_graph
	var has_detached = false
	if "root" not in ship_graph.keys():
		print("Root node has been destroyed")
		for key in ship_graph.keys():
			# Currently when root is destroyed all remaining parts are detached
			# Infuture this could randomly destroy some parts when this happens
			var part = ship_graph.get(key)
			part.part.reparent(get_parent())
			part.part.detached()
			has_detached = true
	else:
		for key in ship_graph.keys():
			var part = ship_graph.get(key)
			if part.neighbors == []:
				print("part is not connected to any other parts.")
				part.part.reparent(get_parent())
				part.part.detached()
				has_detached = true
		
		# Following is to search if a colection of parts have been severed
		# from the root node.
		if not has_detached:
			var nodes_to_visit = []
			var visited_nodes = []
			var root_node = ship_graph.get("root")
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
					part.part.reparent(get_parent())
					part.part.detached()
					has_detached = true
	
	init_components()
