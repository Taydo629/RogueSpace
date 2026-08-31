class_name StationUI extends Control

@onready var market: ItemList = $Station_UI_menu/MarketContainer/Market
@onready var buy_button: Button = $Station_UI_menu/MarketContainer/ButtonContainer/BuyButton
@onready var sell_button: Button = $Station_UI_menu/MarketContainer/ButtonContainer/SellButton
@onready var item_info: Label = $Station_UI_menu/MarketContainer/ButtonContainer/ItemInfo
@onready var j_b_info_label: Label = $Station_UI_menu/JumpBuildServices/ButtonContainer/J_B_InfoLabel
@onready var credit_ui: Label = $CreditUI

@export var inventory_parts: Array[Part] = []

signal exit_station
signal enter_build
signal jump_to_new_level

func _ready() -> void:
	for part in inventory_parts:
		market.add_item(part.name, part.image)

func init_ui() -> void:
	Inventory.credit_changed.connect(update_credit_ui)
	update_credit_ui(Inventory.wallet)

func update_credit_ui(wallet: int):
	credit_ui.text = str("CR ", wallet)

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
	jump_to_new_level.emit()

func _on_build_button_pressed() -> void:
	var withdrawal_successful = Inventory.withdraw_from_wallet(50)
	if not withdrawal_successful:
		j_b_info_label.text = "Insufficient credits to build!"
		return
	# Get game scene
	enter_build.emit()

func _on_exit_button_pressed() -> void:
	exit_station.emit()
