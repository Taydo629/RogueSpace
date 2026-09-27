extends GridContainer

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if get_rect().has_point(at_position):
		return true
	else:
		return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is InventoryItem:
		data.reparent(self)
	else:
		print("Node being dropped is not InventoryItem")
