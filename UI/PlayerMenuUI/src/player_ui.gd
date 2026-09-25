class_name PlayerUI extends Control

@onready var pickup_ui: HBoxContainer = $Pickup_UI
#@onready var direction_indicator: Control = $DirectionIndicator
#@onready var credit_ui: Label = $CreditUI
@onready var sector_label: Label = $SectorLabel
@onready var hint_panel: Panel = $HintPanel
@onready var hud: Node2D = $HUD
@onready var energy_ui: MarginContainer = $EnergyUI
@onready var warp_button: Button = $WarpButton

var parent: MainUILayer
var player: Player
var level_generator: LevelGenComponent
var enemy_array: Array[npc]
#var station: StaticBody2D

var enemy_hud_indicators: Array[Dictionary]
#var station_hud_indicator: Dictionary

const ENEMY_DIRECTION_HUD = preload("uid://8o6kdkj546o3")
#const STATION_DIRECTION_HUD = preload("uid://dfl6i5lki8rxw")

#signal enter_station
signal player_died
signal warp

func init_ui() -> void:
	set_process(true)
	warp_button.disabled = true
	warp_button.text = "Warp unavailable"
	parent = get_parent()
	player = parent.player
	if not player.player_died.is_connected(death):
		player.player_died.connect(death)
	energy_ui.energy_component = player.energy_component
	level_generator = parent.level_gen
	enemy_array = level_generator.current_enemy_array
	print("Player UI initialised")
	print(enemy_array)
	#station = level_generator.current_station
	#if not Inventory.credit_changed.is_connected(update_credit_ui):
		#Inventory.credit_changed.connect(update_credit_ui)
	update_sector_label(level_generator.level_number, level_generator.current_quadrant.position)
	#update_credit_ui(Inventory.wallet)
	update_energy_ui()
	update_hud()

func death() -> void:
	player_died.emit()

func update_sector_label(sector_num: int, quadrant_pos: Vector2) -> void:
	sector_label.text = "Sector %s : Quadrant A%s.B%s" % [sector_num, int(quadrant_pos.x), int(quadrant_pos.y)]

#func update_credit_ui(wallet: int):
	#credit_ui.text = str("CR ", wallet)

func item_pickup(part: Part) -> void:
	pickup_ui.pickup_notif(part)

func update_hud() -> void:
	if not enemy_hud_indicators.is_empty():
		for enemy in enemy_hud_indicators:
			enemy.get("indicator").queue_free()
	#if not station_hud_indicator.is_empty():
		#station_hud_indicator.get("indicator").queue_free()
	enemy_hud_indicators.clear()
	#station_hud_indicator.clear()
	
	for new_npc in enemy_array:
		var new_npc_hud_indicator = ENEMY_DIRECTION_HUD.instantiate()
		hud.add_child(new_npc_hud_indicator)
		enemy_hud_indicators.append({"indicator": new_npc_hud_indicator, "node": new_npc})

func update_energy_ui() -> void:
	energy_ui.init_energy_ui()

func _process(_delta: float) -> void:
	if len(enemy_hud_indicators) != 0:
		for enemy in enemy_hud_indicators:
			var enemy_node = enemy.get("node")
			var enemy_hud = enemy.get("indicator")
			if enemy_node == null:
				enemy_hud_indicators.erase(enemy)
				enemy_hud.queue_free()
			else:
				if player.global_position.distance_to(enemy_node.global_position) <= 1200:
					enemy_hud.visible = false
				else:
					enemy_hud.visible = true
				var direction = (enemy_node.global_position - player.global_position).normalized()
				enemy_hud.rotation = (Vector2.UP).angle_to(direction)
	else:
		warp_button.disabled = false
		warp_button.text = "Warp Ready!"
		set_process(false)
	#elif not station_hud_indicator.is_empty():
		#var station_node = station_hud_indicator.get("node")
		#if station_node != null:
			#var station_hud = station_hud_indicator.get("indicator")
			#if player.global_position.distance_to(station_node.global_position) <= 1200:
				#station_hud.visible = false
				#hint_panel.visible = true
				#if Input.is_action_just_pressed("e"):
					#enter_station.emit()
			#else:
				#station_hud.visible = true
				#hint_panel.visible = false
			#var direction = (station_node.global_position - player.global_position).normalized()
			#station_hud.rotation = (Vector2.UP).angle_to(direction)


func _on_warp_button_pressed() -> void:
	warp.emit()
