extends Node2D

var ship_object: ShipObject
const ASTEROID = preload("uid://c8xodk0qkunlp")
const NPC_SHIP_NEW = preload("uid://c4rflhs7u6xny")
const STATION = preload("uid://baad6rfav87i3")
const SHIP_OBJECT = preload("uid://cf1du3owblsrl")
const PLAYER_UI_LAYER = preload("uid://b7axk8e3fxsiw")
const SHIP_BUILDING = preload("uid://nofp6gunbxci")

@onready var shipbuilding_layer: CanvasLayer = $ShipbuildingLayer
@onready var environment: Node2D = $Environment

var current_level: int = 1
var player_ui: CanvasLayer

signal level_changed

# This triggers when the scene enters the main scene.
func _on_ready() -> void:
	print("Entered main screen")
	open_ship_building()
	generate_level()
	#if ShipInfo.ship_graph == {}:
		## Ship has not been initialised hence go to shipbuilding.
		#ship_building.visible = true
	#else:
		#ship_object = SHIP_OBJECT.instantiate()
		#add_child(ship_object)
		#generate_level()
		#ship_object.init_ship()
		#add_child(PLAYER_UI_LAYER.instantiate())

func open_ship_building() -> void:
	shipbuilding_layer.add_child(SHIP_BUILDING.instantiate())

func generate_level() -> void:
	print(current_level)
	level_changed.emit(current_level)
	if current_level > 1:
		# Set player to start position
		var old_enviornment = environment.get_children()
		for node in old_enviornment:
			node.queue_free()
		var remaining_nodes = get_children()
		for node in remaining_nodes:
			if node.is_in_group("station"):
				node.queue_free()
	# Asteroid generation
	var number_asteroid = randi_range(10,15)
	for i in number_asteroid:
		var asteroid_instance = ASTEROID.instantiate()
		asteroid_instance.global_position = Vector2(randi_range(-8000,8000),randi_range(-8000,8000))
		asteroid_instance.rotation = randf_range(0,2) * PI
		environment.add_child(asteroid_instance)
	# Spawn NPCs
	var number_NPC = randi_range(0 + current_level,1 + current_level)
	#var number_NPC = 0
	for i in number_NPC:
		var npc_instance = NPC_SHIP_NEW.instantiate()
		npc_instance.global_position = Vector2(randi_range(-8000,8000),randi_range(-8000,8000))
		add_child(npc_instance)
	# Spawn Station
	var station_instance = STATION.instantiate()
	station_instance.global_position = Vector2(randi_range(-8000,8000),randi_range(-8000,8000))
	#station_instance.global_position = Vector2(100,100)
	station_instance.rotation = randf_range(0,2) * PI
	add_child(station_instance)
	if current_level > 1:
		ship_object.get_tree().paused = false
		ship_object.init_ship()
		ship_object.global_position = Vector2.ZERO
	current_level += 1

func init_player() -> void:
	if ship_object == null:
		# Instantiate player ship
		ship_object = SHIP_OBJECT.instantiate()
		add_child(ship_object)
		ship_object.init_ship()
		player_ui = PLAYER_UI_LAYER.instantiate()
		add_child(player_ui)
	else:
		ship_object.init_ship()
		ship_object.get_tree().paused = false
