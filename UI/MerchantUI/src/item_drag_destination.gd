extends GridContainer

func _can_drop_data(at_position: Vector2, _data: Variant) -> bool:
	print(self)
	if get_rect().has_point(at_position):
		return true
	else:
		return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	print(self)
	if data is InventoryItem:
		data.reparent(self)
	else:
		print("Node being dropped is not InventoryItem")
