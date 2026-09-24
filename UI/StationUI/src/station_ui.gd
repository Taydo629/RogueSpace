class_name StationUI extends Control

#@onready var market: ItemList = $Station_UI_menu/MarketContainer/Market
@onready var item_info: Label = $Station_UI_menu/MarginContainer/Panel/MarginContainer/MarketContainer/ButtonContainer/ItemInfo
@onready var j_b_info_label: Label = $Station_UI_menu/JumpBuildServices/ButtonContainer/J_B_InfoLabel
@onready var credit_ui: Label = $CreditUI
@onready var market: GridContainer = $Station_UI_menu/MarginContainer/Panel/MarginContainer/MarketContainer/Market
@onready var buy_market: GridContainer = $Station_UI_menu/MarginContainer2/Panel/MarginContainer/MarketContainer/BuyMarket
@onready var buy_item_info: Label = $Station_UI_menu/MarginContainer2/Panel/MarginContainer/MarketContainer/ButtonContainer/BuyItemInfo

@export var inventory_parts: Array[Part] = []

var current_selected_grid: PartItemGrid
var current_selected_grid_to_buy: BuyItemGrid

const PART_ITEM_GRID = preload("uid://dfbu8mcw66h2b")
const BUY_ITEM_GRID = preload("uid://ccuexe6fyayh4")

signal exit_station
signal enter_build
signal jump_to_new_level

func _ready() -> void:
	init_buy_grid()

func init_ui() -> void:
	if not Inventory.credit_changed.is_connected(update_credit_ui):
		Inventory.credit_changed.connect(update_credit_ui)
	update_credit_ui(Inventory.wallet)
	init_sell_grid()

func update_credit_ui(wallet: int):
	credit_ui.text = str("CR ", wallet)

## Sell market specific code

func init_sell_grid() -> void:
	var market_grid_items: Array[Node] = market.get_children()
	if len(market_grid_items) > 0:
		for item: PartItemGrid in market_grid_items:
			item.queue_free()
	for part in Inventory.inventory:
		if part is Part:
			var new_item_grid: PartItemGrid = PART_ITEM_GRID.instantiate()
			new_item_grid.part = part
			market.add_child(new_item_grid)
			new_item_grid.grid_hovered.connect(hovered_grid)
			new_item_grid.grid_clicked.connect(clicked_grid)
			#new_item_grid.grid_not_hovered.connect(stop_hovered_grid)

func hovered_grid(grid: Control) -> void:
	if grid is PartItemGrid:
		var itemgrid: PartItemGrid = grid
		if current_selected_grid == null:
			var focused_part: Part = itemgrid.part
			var part_worth: float = focused_part.sell_price * (float(focused_part.current_health)/float(focused_part.max_health))
			var info_string: String = "%s : \n Part health: %d/%d \n Sell for: %d CR"
			item_info.text = info_string % [focused_part.name,
											focused_part.current_health,
											focused_part.max_health,
											part_worth]

func clicked_grid(grid: Control) -> void:
	if grid is PartItemGrid:
		var itemgrid: PartItemGrid = grid
		if current_selected_grid != itemgrid:
			if current_selected_grid != null:
				current_selected_grid.unselect()
			current_selected_grid = null
			hovered_grid(itemgrid)
			current_selected_grid = itemgrid
	elif grid is BuyItemGrid:
		var itemgrid: BuyItemGrid = grid
		if current_selected_grid_to_buy != itemgrid:
			print_debug(grid is BuyItemGrid)
			if current_selected_grid_to_buy != null:
				current_selected_grid_to_buy.unselect()
			current_selected_grid_to_buy = null
			hovered_grid(itemgrid)
			current_selected_grid_to_buy = itemgrid
			

func _on_market_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if current_selected_grid != null:
			current_selected_grid.unselect()
		current_selected_grid = null

func _on_sell_button_pressed() -> void:
	if current_selected_grid != null:
		var part_to_sell: Part = current_selected_grid.part
		var credits_due := int((float(part_to_sell.current_health)/float(part_to_sell.max_health))*float(part_to_sell.sell_price))
		Inventory.deposit_to_wallet(credits_due)
		Inventory.remove_item(part_to_sell)
		current_selected_grid.unselect()
		current_selected_grid.queue_free()
		current_selected_grid = null

## Buy market code

func init_buy_grid() -> void:
	var buy_market_grid_items: Array[Node] = buy_market.get_children()
	if len(buy_market_grid_items) > 0:
		for item: BuyItemGrid in buy_market_grid_items:
			item.queue_free()
	for part in inventory_parts:
		print(part)
		if part is Part:
			var new_item_grid: BuyItemGrid = BUY_ITEM_GRID.instantiate()
			new_item_grid.part = part
			buy_market.add_child(new_item_grid)
			new_item_grid.grid_hovered.connect(hovered_grid)
			new_item_grid.grid_clicked.connect(clicked_grid)
			#new_item_grid.grid_not_hovered.connect(stop_hovered_grid)

func _on_buy_market_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if current_selected_grid_to_buy != null:
			current_selected_grid_to_buy.unselect()
		current_selected_grid_to_buy = null

func _on_buy_button_pressed() -> void:
	if current_selected_grid_to_buy != null:
		var part_to_buy: Part = current_selected_grid_to_buy.part
		var credits_required := part_to_buy.buy_price
		if not Inventory.withdraw_from_wallet(credits_required):
			buy_item_info.text = "Not enough credits!"
		else:
			Inventory.add_item(part_to_buy)
			current_selected_grid_to_buy.unselect()
			current_selected_grid_to_buy = null
#func stop_hovered_grid(itemgrid: PartItemGrid) -> void:
	#if not Rect2(Vector2(), item_hover_popup.size).has_point(get_local_mouse_position()):
		## Not hovering over popup as well.
		#item_hover_popup.visible = true

#func _on_market_item_selected(index: int) -> void:
	#var item_name = market.get_item_text(index)
	#for part in inventory_parts:
		#if part.name == item_name:
			#var item_count:int = Inventory.inventory.count(part)
			#item_info.text = str(item_count, " in inventory.")
			#buy_button.text = str("Buy (", part.buy_price, " CR)")
			#sell_button.text = str("Sell (", part.sell_price, " CR)")

#func _on_buy_button_pressed() -> void:
	#var selected_idx = market.get_selected_items()
	#if len(selected_idx) > 0:
		#var item_name = market.get_item_text(selected_idx[0])
		#for part in inventory_parts:
			#if part.name == item_name:
				#var withdrawal_successful = Inventory.withdraw_from_wallet(part.buy_price)
				#if not withdrawal_successful:
					#item_info.text = "Insufficient credits!"
					#return
				#else:
					#Inventory.add_item(part)
					#_on_market_item_selected(selected_idx[0])
	#else:
		#item_info.text = "No part selected!"

#func _on_sell_button_pressed() -> void:
	#var selected_idx = market.get_selected_items()
	#if len(selected_idx) > 0:
		#var item_name = market.get_item_text(selected_idx[0])
		#for part in inventory_parts:
			#if part.name == item_name:
				#if Inventory.inventory.count(part) > 0:
					#Inventory.deposit_to_wallet(part.sell_price)
					#Inventory.remove_item(part)
					#_on_market_item_selected(selected_idx[0])
				#else:
					#item_info.text = "No part to sell!"
					#
	#else:
		#item_info.text = "No part selected!"

func _on_jump_button_pressed() -> void:
	# Making jumping free
	#var withdrawal_successful = Inventory.withdraw_from_wallet(100)
	#if not withdrawal_successful:
		#j_b_info_label.text = "Insufficient credits to jump!"
		#return
	# Get game scene
	jump_to_new_level.emit()

func _on_build_button_pressed() -> void:
	# Making building free
	#var withdrawal_successful = Inventory.withdraw_from_wallet(50)
	#if not withdrawal_successful:
		#j_b_info_label.text = "Insufficient credits to build!"
		#return
	# Get game scene
	enter_build.emit()

func _on_exit_button_pressed() -> void:
	exit_station.emit()
