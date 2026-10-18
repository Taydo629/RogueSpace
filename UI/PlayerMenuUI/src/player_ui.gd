class_name PlayerUI extends Control

@onready var pickup_ui: HBoxContainer = $Pickup_UI
@onready var sector_label: Label = $SectorLabel
@onready var hint_panel: Panel = $HintPanel
@onready var radar_hud: TextureRect = $RadarHUD
@onready var energy_ui: MarginContainer = $EnergyUI
@onready var warp_button: Button = $WarpButton
@onready var player_blip: Polygon2D = $RadarHUD/PlayerBlip

@export var radar_range: float = 3000

var parent: MainUILayer
var player: Player
var level_generator: LevelGenComponent
var enemy_array: Array[npc]
var update_hud_flag: bool = true

const ENEMY_BLIP = preload("uid://jhxoa11srl4l")

signal player_died
signal warp

func init_ui() -> void:
	update_hud_flag = true
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
	update_sector_label(level_generator.sector_number, level_generator.current_quadrant.position)
	#update_credit_ui(Inventory.wallet)
	update_energy_ui()
	update_hud()

func death() -> void:
	player_died.emit()

func update_sector_label(sector_num: int, quadrant_pos: Vector2) -> void:
	sector_label.text = "Sector %s : Quadrant %s-%s" % [sector_num, int(quadrant_pos.x), int(quadrant_pos.y)]

#func update_credit_ui(wallet: int):
	#credit_ui.text = str("CR ", wallet)

func item_pickup(part: Part) -> void:
	pickup_ui.pickup_notif(part)

func update_hud() -> void:
	if EnemyBlip in radar_hud.get_children():
		for blip in radar_hud.get_children():
			if blip is EnemyBlip:
				blip.queue_free()
	
	for new_npc in enemy_array:
		var new_npc_blip:EnemyBlip = ENEMY_BLIP.instantiate()
		radar_hud.add_child(new_npc_blip)
		new_npc_blip.player = player
		new_npc_blip.enemy = new_npc
		new_npc_blip.radar_center_pos = radar_hud.position + pivot_offset
		new_npc_blip.radar_circle_radius = radar_hud.size.x/2
		new_npc_blip.radar_range = radar_range

func update_energy_ui() -> void:
	energy_ui.init_energy_ui()

func _process(_delta: float) -> void:
	# Rotate Player blip
	player_blip.rotation = player.rotation
	if update_hud_flag:
		if radar_hud.get_children().size() == 1:
			update_hud_flag = false
			warp_button.disabled = false
			warp_button.text = "Warp Ready!"


func _on_warp_button_pressed() -> void:
	warp.emit()
