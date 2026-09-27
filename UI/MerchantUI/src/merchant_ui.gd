class_name MerchantUI extends Control

@onready var dialog_box_bg: PanelContainer = $DialogBoxBG
@onready var buy_menu_bg: PanelContainer = $BuyMenuBG
@onready var sell_menu_h_box: HBoxContainer = $SellMenuHBox
@onready var item_container: HBoxContainer = $BuyMenuBG/VBoxContainer/ItemContainer
@onready var sell_grid_container: GridContainer = $SellMenuHBox/SellPanelContainer/VBoxContainer/PanelContainer/ScrollContainer/SellGridContainer
@onready var inv_grid_container: GridContainer = $SellMenuHBox/InventoryPanelContainer/VBoxContainer/PanelContainer/ScrollContainer/InvGridContainer
@onready var current_value_label: Label = $SellMenuHBox/SellPanelContainer/VBoxContainer/CurrentValueLabel

@export var tween_in_animation_time: float = 0.3
@export var number_of_items_for_sale: int = 5

var dialog_box_last_pos: Vector2
var buy_menu_last_pos: Vector2
var sell_menu_last_pos: Vector2
var part_list: Array[Part]

const parts_res_dir = "res://data/Parts/"
const MERCHANT_ITEM = preload("uid://c4j3o05v1cybp")
const INVENTORY_ITEM = preload("uid://djfievkxd0ryk")

signal warp

func _ready() -> void:
	_load_all_parts()
	

func init_ui() -> void:
	_update_sell_value()
	_select_stock()

func _update_inventory() -> void:
	if not Inventory.inventory.is_empty():
		for item:Part in Inventory.inventory:
			var new_item_icon: InventoryItem = INVENTORY_ITEM.instantiate()
			inv_grid_container.add_child(new_item_icon)
			new_item_icon.part = item

func _clear_inv_grid() -> void:
	for item_icon: InventoryItem in inv_grid_container.get_children():
		item_icon.queue_free()

func _select_stock() -> void:
	for i in number_of_items_for_sale:
		var selected_part: Part = part_list.pick_random().duplicate()
		var item_node: MerchantItem = MERCHANT_ITEM.instantiate()
		item_container.add_child(item_node)
		item_node.part = selected_part

func _load_all_parts() -> void:
	for resource in ResourceLoader.list_directory(parts_res_dir):
		part_list.append(load(str(parts_res_dir,resource)))

func _reparent_item_to_ui(item_icon: InventoryItem) -> void:
	print("Reparenting node")
	item_icon.reparent(self)

func _evaluate_item_drag(item_icon: InventoryItem) -> void:
	print("Resolving node parenting")
	# if some condition reparent to sell_grid_container
	
	# else reparent to inv_grid_container
	item_icon.reparent(inv_grid_container)

func _on_shop_button_pressed() -> void:
	_tween_dialog_box(false)
	_tween_buy_menu(true)

func _on_sell_button_pressed() -> void:
	_update_inventory()
	_tween_sell_menu(true)
	_tween_dialog_box(false)

func _tween_dialog_box(is_tween_in: bool) -> void:
	var tween:= create_tween()
	var current_rect:= get_rect()
	var dialog_box_target_pos: Vector2
	if is_tween_in:
		dialog_box_target_pos = dialog_box_last_pos
	else:
		dialog_box_target_pos = Vector2(dialog_box_bg.position.x, current_rect.size.y)
		dialog_box_last_pos = dialog_box_bg.position
		
	tween.tween_property(dialog_box_bg, "position", dialog_box_target_pos, tween_in_animation_time)

func _tween_buy_menu(is_tween_in: bool) -> void:
	var tween:= create_tween()
	var current_rect:= get_rect()
	var buy_menu_target_pos: Vector2
	if is_tween_in:
		buy_menu_target_pos = current_rect.size/2 - buy_menu_bg.pivot_offset
		buy_menu_last_pos = buy_menu_bg.position
		for item: MerchantItem in item_container.get_children():
			item.check_affordable()
	else:
		buy_menu_target_pos = buy_menu_last_pos
		
	tween.tween_property(buy_menu_bg, "position", buy_menu_target_pos, tween_in_animation_time)

func _tween_sell_menu(is_tween_in: bool) -> void:
	var tween:= create_tween()
	var current_rect:= get_rect()
	var sell_menu_target_pos: Vector2
	if is_tween_in:
		sell_menu_target_pos = current_rect.size/2 - sell_menu_h_box.pivot_offset
		sell_menu_last_pos = sell_menu_h_box.position
	else:
		sell_menu_target_pos = sell_menu_last_pos
		
	tween.tween_property(sell_menu_h_box, "position", sell_menu_target_pos, tween_in_animation_time)

func _update_sell_value() -> void:
	if len(sell_grid_container.get_children()) == 0:
		current_value_label.text = "Drag items to sell"
		return
	var value_str: String = "Current Value: %s CR"
	var total_value: int = 0
	for item: InventoryItem in sell_grid_container.get_children():
		total_value += item.part.sell_price
	current_value_label.text = value_str % total_value

func _on_leave_button_pressed() -> void:
	# Clear sell box contents when leaving UI
	_on_clear_sell_box_button_pressed()
	warp.emit()

func _on_exit_buy_menu_button_pressed() -> void:
	_tween_dialog_box(true)
	_tween_buy_menu(false)

func _on_exit_sell_menu_button_pressed() -> void:
	_tween_dialog_box(true)
	_tween_sell_menu(false)
	# Code to clear sell menu changes

func _on_sell_grid_container_child_order_changed() -> void:
	_update_sell_value()

func _on_clear_sell_box_button_pressed() -> void:
	for item: InventoryItem in sell_grid_container.get_children():
		item.reparent(inv_grid_container)

func _on_sell_item_button_pressed() -> void:
	for item: InventoryItem in sell_grid_container.get_children():
		if not Inventory.inventory.is_empty():
			Inventory.remove_item(item.part)
			Inventory.deposit_to_wallet(item.part.sell_price)
			item.queue_free()
