extends TabContainer

var inventory_parts: Array[Part] = []
@onready var market: ItemList = $Station_UI/MarketContainer/Market
@onready var buy_button: Button = $Station_UI/MarketContainer/ButtonContainer/BuyButton
@onready var sell_button: Button = $Station_UI/MarketContainer/ButtonContainer/SellButton
@onready var item_info: Label = $Station_UI/MarketContainer/ButtonContainer/ItemInfo
@onready var j_b_info_label: Label = $Station_UI/JumpBuildServices/ButtonContainer/J_B_InfoLabel
const CORE = preload("uid://dxn6vqjt4j07d")
const GUN = preload("uid://bs8ufgr7qnr1y")
const HULL = preload("uid://rp4s55105tbn")
const THRUSTER = preload("uid://b4k0ewhy4bwpf")
const TRACTOR_BEAM = preload("uid://nxtyhwldok2c")

func _ready() -> void:
	load_all_parts_from_folder("res://data/Parts/")
	for part in inventory_parts:
		market.add_item(part.name, part.image)

func load_all_parts_from_folder(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore subdirectories and non-resource files
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = path + "/" + file_name
				var part_resource = load(full_path) as Part
				
				if part_resource:
					inventory_parts.append(part_resource)
					
			file_name = dir.get_next()
		dir.list_dir_end()
		
	print("Total loaded parts: ", inventory_parts.size())

func _on_market_item_selected(index: int) -> void:
	var item_name = market.get_item_text(index)
	for part in inventory_parts:
		if part.name == item_name:
			var item_count:int = Inventory.inventory.count(part)
			item_info.text = str(item_count, " in inventory.")
			buy_button.text = str("Buy (", part.buy_price, " CR)")
			sell_button.text = str("Sell (", part.sell_price, " CR)")

func _on_buy_button_pressed() -> void:
	var selected_idx = market.get_selected_items()
	if len(selected_idx) > 0:
		var item_name = market.get_item_text(selected_idx[0])
		for part in inventory_parts:
			if part.name == item_name:
				var withdrawal_successful = Inventory.withdraw_from_wallet(part.buy_price)
				if not withdrawal_successful:
					item_info.text = "Insufficient credits!"
					return
				else:
					Inventory.add_item(part)
					_on_market_item_selected(selected_idx[0])
	else:
		item_info.text = "No part selected!"

func _on_sell_button_pressed() -> void:
	var selected_idx = market.get_selected_items()
	if len(selected_idx) > 0:
		var item_name = market.get_item_text(selected_idx[0])
		for part in inventory_parts:
			if part.name == item_name:
				if Inventory.inventory.count(part) > 0:
					Inventory.deposit_to_wallet(part.sell_price)
					Inventory.remove_item(part)
					_on_market_item_selected(selected_idx[0])
				else:
					item_info.text = "No part to sell!"
					
	else:
		item_info.text = "No part selected!"

func _on_jump_button_pressed() -> void:
	var withdrawal_successful = Inventory.withdraw_from_wallet(100)
	if not withdrawal_successful:
		j_b_info_label.text = "Insufficient credits to jump!"
		return
	# Get game scene
	get_parent().get_parent().get_parent().generate_level()
	visible = false

func _on_build_button_pressed() -> void:
	var withdrawal_successful = Inventory.withdraw_from_wallet(50)
	if not withdrawal_successful:
		j_b_info_label.text = "Insufficient credits to build!"
		return
	# Get game scene
	get_parent().get_parent().get_parent().open_ship_building()
	get_parent().get_parent().visible = false
