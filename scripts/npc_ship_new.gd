extends RigidBody2D

@export var hull: Part
@export var thruster: Part
@export var gun: Part
var x_min = -160
var y_min = -160
var parts: Array
var ship_graph: Dictionary
@onready var gun_component: GunComponent = $GunComponent

func _ready() -> void:
	ship_graph = {
		"root": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(3,1),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["2","3"]
		},
		"2": {
			"part": gun,
			"colider": null,
			"grid_pos": Vector2(4,1),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["root","4"]
		},
		"3": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(3,2),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["root","4","5"]
		},
		"4": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(4,2),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["2","3","6"]
		},
		"5": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(3,3),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["3","6","7"]
		},
		"6": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(4,3),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["4","5","8"]
		},
		"7": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(3,4),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["5","8"]
		},
		"8": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(4,4),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["6","7"]
		}
	}
	init_ship()

func init_ship():
	for key in ship_graph.keys():
		var node = ship_graph.get(key)
		var part = node.part.scene.instantiate()
		var colider = node.part.collider.instantiate()
		var x = x_min + node.grid_pos.x * 64
		var y = y_min + node.grid_pos.y * 64
		node.part = part
		node.colider = colider
		part.position = Vector2(x,y)
		part.rotation_degrees = node.rotation
		if node.mirrored:
			part.scale = Vector2(-1,1)
			colider.scale = Vector2(-1,1)
		colider.position = Vector2(x,y)
		add_child(part)
		add_child(colider)
		part.colider = colider
		part.dict_key = key
	init_components()

func init_components() -> void:
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_AUTO
	#if gyro_component:
		#gyro_component.active_ship = self
	#thrust_component.update_thrusters()
	gun_component.update_guns()

func part_destroyed(graph_key:String):
	var destroyed_node = ship_graph.get(graph_key)
	print(destroyed_node)
	print(graph_key)
	for neighbor_key in destroyed_node.neighbors:
		var neighbor = ship_graph.get(neighbor_key)
		for key in neighbor.neighbors:
			if key == graph_key:
				neighbor.neighbors.erase(key)
	ship_graph.erase(graph_key)
	call_deferred("check_integrity",graph_key)

func check_integrity(removed_key: String) -> void:
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
				
				
	
