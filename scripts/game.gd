extends Node2D

var ship_object: ShipObject
const ASTEROID = preload("uid://c8xodk0qkunlp")
const NPC_SHIP_NEW = preload("uid://c4rflhs7u6xny")
const STATION = preload("uid://baad6rfav87i3")
const SHIP_OBJECT = preload("uid://cf1du3owblsrl")
const PLAYER_UI_LAYER = preload("uid://b7axk8e3fxsiw")

@onready var environment: Node2D = $Environment


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("build_menu"):
		for key in ShipInfo.ship_graph.keys():
			Inventory.add_item(ShipInfo.ship_graph.get(key).get("part"))
		get_tree().change_scene_to_file("res://scenes/ship_building.tscn")

# This triggers when the scene enters the main scene.
func _on_ready() -> void:
	print("Entered main screen")
	if ShipInfo.ship_graph == {}:
		# Ship has not been initialised hence go to shipbuilding.
		get_tree().change_scene_to_file("res://scenes/ship_building.tscn")
	else:
		ship_object = SHIP_OBJECT.instantiate()
		add_child(ship_object)
		generate_level()
		ship_object.init_ship()
		add_child(PLAYER_UI_LAYER.instantiate())

func generate_level() -> void:
	# Asteroid generation
	var number_asteroid = randi_range(10,15)
	for i in number_asteroid:
		var asteroid_instance = ASTEROID.instantiate()
		asteroid_instance.global_position = Vector2(randi_range(-8000,8000),randi_range(-8000,8000))
		asteroid_instance.rotation = randf_range(0,2) * PI
		environment.add_child(asteroid_instance)
	# Spawn NPCs
	#var number_NPC = randi_range(3,6)
	var number_NPC = 0
	for i in number_NPC:
		var npc_instance = NPC_SHIP_NEW.instantiate()
		npc_instance.global_position = Vector2(randi_range(-8000,8000),randi_range(-8000,8000))
		add_child(npc_instance)
	# Spawn Station
	var station_instance = STATION.instantiate()
	#station_instance.global_position = Vector2(randi_range(-8000,8000),randi_range(-8000,8000))
	station_instance.global_position = Vector2(100,100)
	station_instance.rotation = randf_range(0,2) * PI
	add_child(station_instance)
