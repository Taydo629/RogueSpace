class_name LevelGenComponent extends Node

#signal level_generated

var level_number: int = 0
var current_enemy_array: Array[npc]
var current_station: StaticBody2D
var playable_bound_x: Vector2 = Vector2(-7000,7000)
var playable_bound_y: Vector2 = Vector2(-7000,7000)
var main_game: Node2D
const NPC = preload("uid://dxth7s5bap4i5")
const STATION = preload("uid://baad6rfav87i3")

@export var spawn_enemies: bool = true
@export var enemy_spawn_override_count: int = -1
@export var loaded_ships: Array[NPCShip] = []

func _ready() -> void:
	main_game = get_parent()

func generate_level() -> void:
	
	level_number += 1
	# Clear the level before generating new one
	clear_level()
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
	var station_instance = STATION.instantiate()
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
