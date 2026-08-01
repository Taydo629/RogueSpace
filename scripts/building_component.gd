class_name PartComponent extends Node

func initialise_ship() -> void:
	for node in ShipInfo.ship_graph.values():
		var instance = node.part.scene.instantiate()
		instance.rotation = node.rotation
		instance.scale = node.scale
		var off_set: Vector2 = ShipInfo.current_grid_dim/2 * Vector2(64,64)
		instance.position = node.grid_pos * Vector2(64,64) - off_set
		add_child(instance)
		#node.instance = instance
