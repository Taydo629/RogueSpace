extends Node2D

@onready var ship_object: ShipObject = $ShipObject

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
		ship_object.init_ship()
