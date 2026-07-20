extends Node2D

@onready var h_box_container: HBoxContainer = $PanelContainer/HBoxContainer

var root_present: bool = false
var selected_part_rotation: int
var current_slot: int
var part_oob: bool = false
var mirrored: bool = false
var grid: Array = [[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null],
				[null,null,null,null,null]]
var y_range: Array = [192,448]
var x_range: Array = [448,704]

var ship_graph: Dictionary = {}

var increment: int = 1

func _ready() -> void:
	h_box_container.init_hotbar()

func _process(delta: float) -> void:
	var selected_instance = h_box_container.selected_instance
	
	# Handle part mirroring
	if Input.is_action_just_pressed("mirror"):
		if mirrored:
			selected_instance.scale = Vector2(1,1)
			mirrored = false
		else:
			selected_instance.scale = Vector2(-1,1)
			mirrored = true
	
	# Handle part rotation
	if Input.is_action_just_pressed("e"):
		selected_instance.rotation_degrees += 90
	if Input.is_action_just_pressed("q"):
		selected_instance.rotation_degrees += -90
	
	# Get the grid position so that parts are on a grid.
	var mouse_pos = get_global_mouse_position() + Vector2(32,32)
	var pos = Vector2(mouse_pos.x -fmod(mouse_pos.x, 64),mouse_pos.y -fmod(mouse_pos.y, 64))
	
	# Handle parts positioning and handle when mouse pos is outside of building area.
	if pos.x >= x_range[0] and pos.x <= x_range[1] and pos.y <= y_range[1] and pos.y >= y_range[0] :
		part_oob = false
		selected_instance.visible = true
		selected_instance.position = pos
	else:
		part_oob = true
		selected_instance.visible = false
	
	if Input.is_action_just_pressed("left_click") and !part_oob:
		var relative_pos = pos - Vector2(x_range[0],y_range[0])
		place_part(relative_pos)
	if Input.is_action_just_pressed("right_click") and !part_oob:
		var relative_pos = pos - Vector2(x_range[0],y_range[0])
		remove_part(relative_pos)

func place_part(pos: Vector2):
	var x_grid = pos.x / 64
	var y_grid = pos.y / 64
	if grid[x_grid][y_grid] == null:
		var node_dict = {
			"part": h_box_container.selected_part,
			"colider": null,
			"grid_pos": Vector2(x_grid,y_grid),
			"rotation": h_box_container.selected_instance.rotation_degrees,
			"mirrored": mirrored,
			"neighbors": [],
			"instance": h_box_container.selected_instance
		}
		var key: String
		if h_box_container.selected_part.name != "core":
			key = str(increment)
			increment += 1
		else:
			if root_present == true:
				print("Unable to place core part as one has already been placed!")
				return
			root_present = true
			key = "root"
		grid[x_grid][y_grid] = {key: node_dict}
		h_box_container.new_part()
	else:
		print("Grid is occupied!")

func remove_part(pos: Vector2):
	var x_grid = pos.x / 64
	var y_grid = pos.y / 64
	if grid[x_grid][y_grid] == null:
		print("Grid is already empty!")
	else:
		var key = grid[x_grid][y_grid].keys()[0]
		if key == "root":
			root_present = false
		grid[x_grid][y_grid].get(key).get("instance").queue_free()
		grid[x_grid][y_grid] = null 

func _on_build_button_pressed() -> void:
	clear_graph()
	if not root_present:
		print("Root node not found unable to build ship!")
		return
	var i = 1
	# Search for nodes neighbors by traversing the grid
	for row in grid:
		for cell in row:
			if cell != null:
				var key: String = cell.keys()[0]
				var coords_to_search: Array = []
				var node_coord = cell.get(key).get("grid_pos")
				if node_coord.y > 0:
					coords_to_search.append(Vector2(node_coord.x,node_coord.y-1))
				if node_coord.y < len(grid)-1:
					coords_to_search.append(Vector2(node_coord.x,node_coord.y+1))
				if node_coord.x > 0:
					coords_to_search.append(Vector2(node_coord.x-1,node_coord.y))
				if node_coord.x < len(grid[0])-1:
					coords_to_search.append(Vector2(node_coord.x+1,node_coord.y))
				for coords in coords_to_search:
					if grid[coords.x][coords.y] != null:
						cell.get(key).get("neighbors").append(grid[coords.x][coords.y].keys()[0])
				ship_graph.merge(cell)
	
	# Evaluate how many nodes are able to be traversed from the root node
	var nodes_to_visit = []
	var visited_nodes = []
	var root_node = ship_graph.get("root")
	nodes_to_visit.append_array(root_node.neighbors)
	var search_complete = false
	while not search_complete:
		if nodes_to_visit == []:
			search_complete = true
		else:
			var current_node_key = nodes_to_visit[0]
			visited_nodes.append(current_node_key)
			nodes_to_visit.append_array(ship_graph.get(current_node_key).neighbors)
			nodes_to_visit.erase(current_node_key)
			for node in visited_nodes:
				nodes_to_visit.erase(node)
	
	# If nodes traversable from root is not equal to the number of nodes
	# means there is a disconnect!
	# Need to clear the neighbors of all node
	if len(visited_nodes) != len(ship_graph.keys()):
		print("One or more parts is not attached to anything else!")
		return
	
	# Nice to have for debug
	#print(ship_graph)
	#print(" ")
	#print(" ")
	#print(" ")
	
	ShipInfo.update_ship(ship_graph)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
func clear_graph() -> void:
	for row in grid:
		for cell in row:
			if cell != null:
				var key: String = cell.keys()[0]
				cell.get(key).set("neighbors",[])
				ship_graph = {}
