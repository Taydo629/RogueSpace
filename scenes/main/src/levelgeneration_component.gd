class_name LevelGenComponent extends Node

signal level_ready(Quadrant)

var level_number: int = 0
var current_enemy_array: Array[npc]
var current_station: StaticBody2D
var playable_bound_x: Vector2 = Vector2(-7000,7000)
var playable_bound_y: Vector2 = Vector2(-7000,7000)
var main_game: Node2D
var player: Player
var map_ui: MapUI
const NPC = preload("uid://dxth7s5bap4i5")
const STATION = preload("uid://baad6rfav87i3")
const PLAYER = preload("uid://tqn70usw28ix")
@export var sector_width: int = 5
@export var layers: int = 10
@export var num_of_paths: int = 3
var current_quadrant: Quadrant
var map_grid: Array[Array]:
	set(value):
		map_grid = value
		map_ui.map_grid = map_grid

@export var spawn_enemies: bool = true
@export var enemy_spawn_override_count: int = -1
@export var loaded_ships: Array[NPCShip] = []

func generate_map() -> void:
	# Create and initial grid of quadrants
	var initial_map_grid: Array[Array] = []
	for i in layers:
		var layer_array: Array[Quadrant]
		for j in sector_width:
			var new_quadrant: Quadrant = Quadrant.new()
			new_quadrant.position = Vector2(i,j)
			new_quadrant.next_quadrant = []
			layer_array.append(new_quadrant)
		initial_map_grid.append(layer_array)
	
	# Randomise quadrant type
	for layer in initial_map_grid:
		for quadrant: Quadrant in layer:
			quadrant.set_random_type()
	
	# Add in the boss quadrant
	var boss_quadrant: Quadrant = Quadrant.new()
	@warning_ignore("integer_division")
	var mid_point_row: int = sector_width/2
	print(mid_point_row)
	var boss_pos: Vector2 = Vector2(layers - 1, mid_point_row)
	boss_quadrant.position = Vector2(layers - 1,mid_point_row)
	boss_quadrant.type = Quadrant.TYPE.BOSS
	initial_map_grid[layers - 1][mid_point_row] = boss_quadrant
	
	# Select some rows to start from
	var starting_rows: Array[int] = []
	for path in num_of_paths:
		starting_rows.append(randi_range(0, sector_width-1))
	
	# Create paths
	for starting_point in starting_rows:
		var current_pos:= Vector2(0,starting_point)
		for layer in layers-1:
			var current_quadrant_iter: Quadrant = initial_map_grid[layer][current_pos.y]
			var possible_rows: Array[int] = []
			if current_pos.y > 0:
				possible_rows.append(current_pos.y - 1)
			if current_pos.y < sector_width - 1:
				possible_rows.append(current_pos.y + 1)
			# Check for crossing paths
			for candidate_row in possible_rows:
				var adjacent_quadrant: Quadrant = initial_map_grid[layer][candidate_row]
				if len(adjacent_quadrant.next_quadrant) != 0:
					for next_quadrant in adjacent_quadrant.next_quadrant:
						if next_quadrant.position.y == current_pos.y:
							possible_rows.erase(adjacent_quadrant.position.y)
			possible_rows.append(current_pos.y)
			# Last layer before boss
			if layer == layers -2:
				# Connect second to last layer to boss quadrant
				if initial_map_grid[boss_pos.x][boss_pos.y] not in current_quadrant_iter.next_quadrant:
					current_quadrant_iter.next_quadrant.append(initial_map_grid[boss_pos.x][boss_pos.y])
			else:
				var next_row: int = possible_rows.pick_random()
				if initial_map_grid[layer + 1][next_row] not in current_quadrant_iter.next_quadrant:
					current_quadrant_iter.next_quadrant.append(initial_map_grid[layer + 1][next_row])
				current_pos = Vector2(layer + 1, next_row)
	
	# Create a layer which has combat in the middle
	# This also ensures that at minimum 1 combat exists within each path
	@warning_ignore("integer_division")
	var quater_of_layers: int = layers/4
	@warning_ignore("integer_division")
	var mid_point_layer: int = layers/2
	var combat_layer: int = randi_range(mid_point_layer-quater_of_layers, mid_point_layer+quater_of_layers)
	for j in sector_width:
		var quadrant: Quadrant = initial_map_grid[combat_layer][j]
		quadrant.type = Quadrant.TYPE.COMBAT
	
	# Remove quadrants which have no connections
	for i in layers:
		var quadrant_to_remove: Array[Quadrant] = []
		for j in sector_width:
			var quadrant: Quadrant = initial_map_grid[i][j]
			if len(quadrant.next_quadrant) == 0 and quadrant.type != Quadrant.TYPE.BOSS:
				quadrant_to_remove.append(quadrant)
		for quadrant in quadrant_to_remove:
			quadrant.type = Quadrant.TYPE.EMPTY
	
	# Debug print
	print(initial_map_grid)
	for layer in initial_map_grid:
		for row:Quadrant in layer:
			if row.type != Quadrant.TYPE.EMPTY:
				if len(row.next_quadrant) != 0 or row.type == Quadrant.TYPE.BOSS:
					var next_pos: Array[Vector2]
					for connection: Quadrant in row.next_quadrant:
						next_pos.append(connection.position)
					print("%s at %s with connections to %s" % [row, row.position,next_pos])
	map_grid = initial_map_grid

func _ready() -> void:
	main_game = get_parent()

func init_game() -> void:
	Inventory.init_inventory()
	for child in get_children():
		child.queue_free()
	level_number = 0
	current_enemy_array.clear()
	current_station = null
	player = PLAYER.instantiate()
	player.position = Vector2.ZERO
	add_child(player)
	generate_map()

func generate_level(quadrant: Quadrant) -> void:
	current_quadrant = quadrant
	if current_quadrant.type == Quadrant.TYPE.BOSS:
		generate_map()
	level_number += 1
	# Clear the level before generating new one
	clear_level()
	
	player.position = Vector2.ZERO
	# Spawn enemies if quadrant either boss or combat
	if current_quadrant.type in [Quadrant.TYPE.BOSS, Quadrant.TYPE.COMBAT]:
		# NPC spawning
		var valid_npcs: Array[NPCShip] = get_valid_ships_for_current_level()
		var number_of_npcs: int
		if spawn_enemies:
			if enemy_spawn_override_count < 0:
				number_of_npcs = randi_range(1, level_number)
			else:
				number_of_npcs = enemy_spawn_override_count
		else:
			number_of_npcs = 0
		var npc_array: Array[npc]
		for i in number_of_npcs:
			var NPC_instance = NPC.instantiate()
			var NPC_ship = valid_npcs.pick_random()
			NPC_instance.position = Vector2(randf_range(playable_bound_x.x,playable_bound_x.y),randf_range(playable_bound_y.x,playable_bound_y.y))
			#NPC_instance.position = Vector2(-200,0)
			NPC_instance.ship_graph = NPC_ship.ship_graph.get_dictionary()
			NPC_instance.grid_dim = NPC_ship.grid_size
			add_child(NPC_instance)
			npc_array.append(NPC_instance)
		# Station spawining
		#var station_instance = STATION.instantiate()
		#station_instance.position = Vector2(randf_range(playable_bound_x.x,playable_bound_x.y),randf_range(playable_bound_y.x,playable_bound_y.y))
		#add_child(station_instance)
		current_enemy_array = npc_array
		#current_station = station_instance
		player.position = Vector2.ZERO
		print_debug(player.angular_velocity)
		print_debug(player.constant_torque)
		player.constant_torque = 0
		player.angular_velocity = 0
	if current_quadrant.type == Quadrant.TYPE.NEUTRAL:
		var valid_npcs: Array[NPCShip] = get_valid_ships_for_current_level()
		var NPC_instance = NPC.instantiate()
		var NPC_ship = valid_npcs.pick_random()
		NPC_instance.position = Vector2(randf_range(playable_bound_x.x,playable_bound_x.y),randf_range(playable_bound_y.x,playable_bound_y.y))
		NPC_instance.ship_graph = NPC_ship.ship_graph.get_dictionary()
		NPC_instance.grid_dim = NPC_ship.grid_size
		add_child(NPC_instance)
		current_enemy_array = [NPC_instance]
		player.constant_torque = 0
		player.angular_velocity = 0
	level_ready.emit(current_quadrant)

func get_valid_ships_for_current_level() -> Array[NPCShip]:
	var valid_ships: Array[NPCShip]
	for ship in loaded_ships:
		if level_number >= ship.min_level and level_number <= ship.max_level:
			valid_ships.append(ship.duplicate_deep(Resource.DEEP_DUPLICATE_ALL))
	return(valid_ships)

func clear_level() -> void:
	for child in get_children():
		if child is not Player:
			child.queue_free()
