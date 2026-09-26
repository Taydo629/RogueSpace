class_name MerchantUI extends Control

@onready var dialog_box_bg: PanelContainer = $DialogBoxBG
@onready var buy_menu_bg: PanelContainer = $BuyMenuBG
@onready var item_container: HBoxContainer = $BuyMenuBG/VBoxContainer/ItemContainer

@export var tween_in_animation_time: float = 0.3
@export var number_of_items_for_sale: int = 5

var dialog_box_last_pos: Vector2
var buy_menu_last_pos: Vector2
var part_list: Array[Part]

const parts_res_dir = "res://data/Parts/"
const MERCHANT_ITEM = preload("uid://c4j3o05v1cybp")

signal warp

func _ready() -> void:
	_load_all_parts()
	

func init_ui() -> void:
	_select_stock()
	

func _select_stock() -> void:
	for i in number_of_items_for_sale:
		var selected_part: Part = part_list.pick_random().duplicate()
		var item_node: MerchantItem = MERCHANT_ITEM.instantiate()
		item_container.add_child(item_node)
		item_node.part = selected_part

func _load_all_parts() -> void:
	for resource in ResourceLoader.list_directory(parts_res_dir):
		part_list.append(load(str(parts_res_dir,resource)))

func _on_shop_button_pressed() -> void:
	_tween_dialog_box(false)
	_tween_buy_menu(true)

func _on_sell_button_pressed() -> void:
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

func _on_leave_button_pressed() -> void:
	warp.emit()

func _on_exit_buy_menu_button_pressed() -> void:
	_tween_dialog_box(true)
	_tween_buy_menu(false)
