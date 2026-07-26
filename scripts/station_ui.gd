extends TabContainer

var inventory_parts: Array = []
@onready var market: ItemList = $Market

func _on_visibility_changed() -> void:
	for part in Inventory.inventory:
		if part not in inventory_parts:
			inventory_parts.append(part)
	
	for part in inventory_parts:
		var item_count:int = Inventory.inventory.count(part)
		market.add_item(str(part.name, " X", str(item_count)), part.image)
