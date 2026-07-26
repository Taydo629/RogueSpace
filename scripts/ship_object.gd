class_name ShipObject extends RigidBody2D

@onready var thrust_component: ThrustComponent = $ThrustComponent
@onready var gyro_component: GyroComponent = $GyroComponent
@onready var gun_component: GunComponent = $GunComponent
@onready var tractorbeam_component: TractorbeamComponent = $TractorbeamComponent
@onready var player_input_component: Node = $PlayerInputComponent
@onready var destruction_sound: AudioStreamPlayer2D = $Destruction_sound
const ENEMY_DIRECTION_HUD = preload("uid://8o6kdkj546o3")

var enemy_direction_notifiers: Array
var enemy_array: Array = []

var x_min = -128
var y_min = -128

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
	init_hud()

func init_components() -> void:
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_AUTO
	if gyro_component:
		gyro_component.active_ship = self
	thrust_component.update_thrusters()
	gun_component.update_guns()
	tractorbeam_component.update_tractorbeam()

func init_hud() -> void:
	var siblings = get_parent().get_children()
	print(siblings)
	for sibling in siblings:
		if sibling.is_in_group("enemy"):
			var new_hud_indicator = ENEMY_DIRECTION_HUD.instantiate()
			add_child(new_hud_indicator)
			enemy_array.append({"node": sibling, "hud_indicator": new_hud_indicator})

func part_destroyed(graph_key:String):
	destruction_sound.play()
	var ship_graph = ShipInfo.ship_graph
	var destroyed_node = ship_graph.get(graph_key)
	print("player_ship")
	print(destroyed_node)
	if destroyed_node != null:
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
			part.instance.reparent(get_parent())
			part.instance.detached()
			has_detached = true
			init_components()
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

func _process(delta: float) -> void:
	if len(enemy_array) > 0:
		for enemy in enemy_array:
			var enemy_node = enemy.get("node")
			var enemy_hud = enemy.get("hud_indicator")
			if enemy_node == null:
				enemy_array.erase(enemy)
				enemy_hud.queue_free()
			else:
				if global_position.distance_to(enemy_node.global_position) <= 600:
					enemy_hud.visible = false
				else:
					enemy_hud.visible = true
				var direction = (enemy_node.global_position - global_position).normalized()
				enemy_hud.rotation = (-transform.y).angle_to(direction)
	
