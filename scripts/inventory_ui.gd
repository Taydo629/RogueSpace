extends FoldableContainer

const HOTBAR_UI = preload("uid://d1gia6ahj8i30")
var inventory_parts: Array = []
@onready var grid_container: GridContainer = $GridContainer


func _ready():
	for part in Inventory.inventory:
		var part_in_grid: bool = false
		for icon in inventory_parts:
			if icon.part == part:
				part_in_grid = true
				icon.label.text = str(int(icon.label.text)+1)
		if not part_in_grid:
			var part_icon = HOTBAR_UI.instantiate()
			part_icon.part = part
			grid_container.add_child(part_icon)
			part_icon.update_count(1)
			inventory_parts.append(part_icon)
	
	Inventory.item_pickup.connect(update_item_count)

func update_item_count(part: Part):
	var icon_exists:bool = false
	for slot in inventory_parts:
		if part.name == slot.part.name:
			slot.label.text = str(int(slot.label.text)+1)
			icon_exists = true
	
	if not icon_exists:
		var part_icon = HOTBAR_UI.instantiate()
		part_icon.part = part
		grid_container.add_child(part_icon)
		part_icon.update_count(1)
		inventory_parts.append(part_icon)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		folded = !folded
