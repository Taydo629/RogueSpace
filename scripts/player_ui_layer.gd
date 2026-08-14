extends CanvasLayer

@onready var pickup_ui: HBoxContainer = $Pickup_UI
#@onready var direction_indicator: Control = $DirectionIndicator
@onready var credit_ui: Label = $CreditUI
@onready var sector_label: Label = $SectorLabel
@onready var hud: Node2D = $HUD

var player: Player
var enemy_hud_indicators: Array[Dictionary]
var station_hud_indicator: Dictionary

const ENEMY_DIRECTION_HUD = preload("uid://8o6kdkj546o3")
const STATION_DIRECTION_HUD = preload("uid://dfl6i5lki8rxw")

func _ready() -> void:
	player = get_parent()
	Inventory.credit_changed.connect(update_credit_ui)
	#get_parent().get_parent().level_changed.connect(update_sector_label)
	update_credit_ui(Inventory.wallet)

func update_sector_label(level_num: int) -> void:
	sector_label.text = str("Sector ", str(level_num))

func update_credit_ui(wallet: int):
	credit_ui.text = str("CR ", wallet)

func item_pickup(part: Part) -> void:
	pickup_ui.pickup_notif(part)

func update_hud() -> void:
	if not enemy_hud_indicators.is_empty():
		for enemy in enemy_hud_indicators:
			enemy.get("indicator").queue_free()
	if not station_hud_indicator.is_empty():
		station_hud_indicator.get("indicator").queue_free()
	enemy_hud_indicators.clear()
	station_hud_indicator.clear()
	for new_npc in player.enemy_array:
		var new_npc_hud_indicator = ENEMY_DIRECTION_HUD.instantiate()
		hud.add_child(new_npc_hud_indicator)
		enemy_hud_indicators.append({"indicator": new_npc_hud_indicator, "node": new_npc})
	var new_station_hud_indicator = STATION_DIRECTION_HUD.instantiate()
	new_station_hud_indicator.visible = false
	hud.add_child(new_station_hud_indicator)
	station_hud_indicator = {"indicator": new_station_hud_indicator, "node": player.station}

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
				enemy_hud.rotation = (-transform.y).angle_to(direction)
	else:
		var station_node = station_hud_indicator.get("node")
		var station_hud = station_hud_indicator.get("indicator")
		if player.global_position.distance_to(station_node.global_position) <= 1200:
			station_hud.visible = false
		else:
			station_hud.visible = true
		var direction = (station_node.global_position - player.global_position).normalized()
		station_hud.rotation = (-transform.y).angle_to(direction)
#func _input(event: InputEvent) -> void:
	#pass
