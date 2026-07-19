extends RigidBody2D

@export var hull: Part
@export var thruster: Part
@export var gun: Part
var x_min = -160
var y_min = -160
var parts: Array
var ship_graph: Dictionary

func _ready() -> void:
	ship_graph = {
		"root": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(3,1),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["2"]
		},
		"2": {
			"part": hull,
			"colider": null,
			"grid_pos": Vector2(3,2),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["root","3","4","5"]
		},
		"3": {
			"part": gun,
			"colider": null,
			"grid_pos": Vector2(2,2),
			"rotation": 0,
			"mirrored": true,
			"neighbors": ["2"]
		},
		"4": {
			"part": gun,
			"colider": null,
			"grid_pos": Vector2(4,2),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["2"]
		},
		"5": {
			"part": thruster,
			"colider": null,
			"grid_pos": Vector2(3,3),
			"rotation": 0,
			"mirrored": false,
			"neighbors": ["2"]
		}
	}
	init_ship()

func init_ship():
	for key in ship_graph.keys():
		var node = ship_graph.get(key)
		var part = node.part.scene.instantiate()
		var colider = preload("res://scenes/part_colider.tscn").instantiate()
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

func part_destroyed(graph_key:String):
	var destroyed_node = ship_graph.get(graph_key)
	for neighbor_key in destroyed_node.neighbors:
		var neighbor = ship_graph.get(neighbor_key)
		for key in neighbor.neighbors:
			if key == graph_key:
				neighbor.neighbors.erase(key)
	ship_graph.erase(graph_key)
	call_deferred("check_integrity")

func check_integrity() -> void:
	if "root" not in ship_graph.keys():
		print("Root node has been destroyed")
	else:
		for key in ship_graph.keys():
			var part = ship_graph.get(key)
			if part.neighbors == []:
				print("part is not connected to any other parts.")
				part.part.reparent(get_parent())
				part.part.detached()
	
