class_name LevelGenComponent extends Node

signal level_generated

var level_number: int = 1
var loaded_ships: Array[NPCShip] = []
var playable_bound_x: Vector2 = Vector2.ZERO
var playable_bound_y: Vector2 = Vector2.ZERO
const NPC = preload("uid://dxth7s5bap4i5")

func _ready() -> void:
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
	# NPC spawning
	var valid_npcs: Array[NPCShip] = get_valid_ships_for_current_level()
	var number_of_npcs = 1 # randi_range(4, 8)
	for i in number_of_npcs:
		var NPC_instance = NPC.instantiate()
		var NPC_ship = valid_npcs.pick_random()
		#NPC_instance.position = Vector2(randi_range(playable_bound_x.x,playable_bound_x.y),randi_range(playable_bound_y.x,playable_bound_y.y))
		NPC_instance.position = Vector2(-200,0)
		NPC_instance.ship_graph = NPC_ship.ship_graph.get_dictionary()
		NPC_instance.grid_dim = NPC_ship.grid_size
		add_child(NPC_instance)
	# code to generate level
	level_number += 1
	level_generated.emit()

func get_valid_ships_for_current_level() -> Array[NPCShip]:
	var valid_ships: Array[NPCShip]
	for ship in loaded_ships:
		if level_number >= ship.min_level and level_number <= ship.max_level:
			valid_ships.append(ship)
	return(valid_ships)
