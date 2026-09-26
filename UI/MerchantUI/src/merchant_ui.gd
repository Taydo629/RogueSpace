class_name MerchantUI extends Control

@onready var dialog_box_bg: PanelContainer = $DialogBoxBG
@onready var buy_menu_bg: PanelContainer = $BuyMenuBG
var dialog_box_last_pos: Vector2
var buy_menu_last_pos: Vector2
@export var tween_in_animation_time: float = 0.3

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
	else:
		buy_menu_target_pos = buy_menu_last_pos
		
	tween.tween_property(buy_menu_bg, "position", buy_menu_target_pos, tween_in_animation_time)

func _on_leave_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_buy_menu_button_pressed() -> void:
	_tween_dialog_box(true)
	_tween_buy_menu(false)
