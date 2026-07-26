extends RigidBody2D

@export var hull: Part
@export var thruster: Part
@export var gun: Part
@export var core: Part
var x_min = -128
var y_min = -128
var parts: Array
var ship_graph: Dictionary
@onready var gun_component: GunComponent = $GunComponent
@onready var gyro_component: GyroComponent = $GyroComponent
@onready var thrust_component: ThrustComponent = $ThrustComponent
@onready var vision_area: Area2D = $VisionArea
@onready var destruction_sound: AudioStreamPlayer2D = $Destruction_sound

func _ready() -> void:
	ship_graph = { 
					"11": { 
						"part": gun, 
						"colider": null, 
						"grid_pos": Vector2(1.0, 1.0), 
						"rotation": 0.0, 
						"mirrored": true, 
						"neighbors": ["5", "3"], 
						"instance": null 
					}, 
					"5": { 
						"part": hull, 
						"colider": null, 
						"grid_pos": Vector2(1.0, 2.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["11", "6", "4"], 
						"instance": null
					}, 
					"6": { 
						"part": hull, 
						"colider": null, 
						"grid_pos": Vector2(1.0, 3.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["5", "14", "13"], 
						"instance": null 
					}, 
					"14": { 
						"part": thruster, 
						"colider": null, 
						"grid_pos": Vector2(1.0, 4.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["6"], 
						"instance": null 
					}, 
					"root": { 
						"part": core, 
						"colider": null, 
						"grid_pos": Vector2(2.0, 0.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["3"], 
						"instance": null 
					}, 
					"3": { 
						"part": hull, 
						"colider": null, 
						"grid_pos": Vector2(2.0, 1.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["root", "4", "11", "12"], 
						"instance": null
					}, 
					"4": { 
						"part": hull, 
						"colider": null, 
						"grid_pos": Vector2(2.0, 2.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["3", "13", "5", "7"], 
						"instance": null 
					}, 
					"13": { 
						"part": thruster, 
						"colider": null, 
						"grid_pos": Vector2(2.0, 3.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["4", "6", "8"], 
						"instance": null
					}, 
					"12": { 
						"part": gun, 
						"colider": null, 
						"grid_pos": Vector2(3.0, 1.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["7", "3"], 
						"instance": null
					}, 
					"7": { 
						"part": hull, 
						"colider": null, 
						"grid_pos": Vector2(3.0, 2.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["12", "8", "4"], 
						"instance": null
					}, 
					"8": { 
						"part": hull, 
						"colider": null, 
						"grid_pos": Vector2(3.0, 3.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["7", "15", "13"], 
						"instance": null
					}, 
					"15": { 
						"part": thruster, 
						"colider": null, 
						"grid_pos": Vector2(3.0, 4.0), 
						"rotation": 0.0, 
						"mirrored": false, 
						"neighbors": ["8"], 
						"instance": null
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
		if node.part.name == "core":
#			# Set vision area to core position
			vision_area.position = Vector2(x,y)
		node.instance = part
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

func part_destroyed(graph_key:String):
	destruction_sound.play()
	var destroyed_node = ship_graph.get(graph_key)
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
			part.instance.reparent(get_parent())
			part.instance.detached()
			has_detached = true
		queue_free()
	else:
		for key in ship_graph.keys():
			var part = ship_graph.get(key)
			if part.neighbors == []:
				print("part is not connected to any other parts.")
				part.instance.reparent(get_parent())
				part.instance.detached()
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
					part.instance.reparent(get_parent())
					part.instance.detached()
					has_detached = true
	
	init_components()
