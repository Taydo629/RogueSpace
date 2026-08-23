class_name LevelGenComponent extends Node

signal level_generated

var level_number: int = 0
var loaded_ships: Array[NPCShip] = []
var current_enemy_array: Array[npc]
var current_station: Station
var playable_bound_x: Vector2 = Vector2(-7000,7000)
var playable_bound_y: Vector2 = Vector2(-7000,7000)
var main_game: Node2D
const NPC = preload("uid://dxth7s5bap4i5")
const STATION = preload("uid://baad6rfav87i3")

func _ready() -> void:
	main_game = get_parent()
	load_all_ships_from_folder("res://data/NPCShips/")

func load_all_ships_from_folder(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore subdirectories and non-resource files
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = path + "/" + file_name
				var ship_resource = load(full_path) as NPCShip
				
				if ship_resource:
					loaded_ships.append(ship_resource)
					
			file_name = dir.get_next()
		dir.list_dir_end()
		
	print("Total loaded ships: ", loaded_ships.size())

func generate_level() -> void:
	
	level_number += 1
	# Clear the level before generating new one
	clear_level()
	# NPC spawning
	var valid_npcs: Array[NPCShip] = get_valid_ships_for_current_level()
	var number_of_npcs = randi_range(1, level_number)
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
	var station_instance = STATION.instantiate()
	station_instance.main_game = main_game
	station_instance.position = Vector2(randf_range(playable_bound_x.x,playable_bound_x.y),randf_range(playable_bound_y.x,playable_bound_y.y))
	add_child(station_instance)
	current_enemy_array = npc_array
	current_station = station_instance
	#level_generated.emit(level_number, npc_array, station_instance)

func get_valid_ships_for_current_level() -> Array[NPCShip]:
	var valid_ships: Array[NPCShip]
	for ship in loaded_ships:
		if level_number >= ship.min_level and level_number <= ship.max_level:
			valid_ships.append(ship)
	return(valid_ships)

func clear_level() -> void:
	for child in get_children():
		if child is not Player:
			child.queue_free()
