extends Node2D

#@onready var start_menu_layer: CanvasLayer = $StartMenuLayer
#@onready var pause_menu_layer: CanvasLayer = $PauseMenuLayer
#@onready var ship_building_layer: CanvasLayer = $ShipBuildingLayer
#@onready var station_ui_layer: CanvasLayer = $StationUILayer
#@onready var intro_guide: Control = $IntroGuide
@onready var level_gen_component: LevelGenComponent = $LevelGenComponent
@onready var player: Player = $LevelGenComponent/Player
@onready var ui_state_machine: StateMachine = $UIStateMachine
@onready var main_ui_layer: CanvasLayer = $MainUILayer

func _ready() -> void:
	# Give UI reference to player for player specific UI
	main_ui_layer.player = player
	main_ui_layer.level_gen = level_gen_component
	main_ui_layer.init_ui()
	#start_menu_layer.start.connect(start_game)
	#start_menu_layer.option.connect(options)
	#start_menu_layer.exit.connect(exit)
	#pause_menu_layer.resume.connect(resume_game)
	#pause_menu_layer.option.connect(options)
	#pause_menu_layer.exit.connect(exit)
	#intro_guide.guide_end.connect(exit_guide)
	#station_ui_layer.exit_station.connect(exit_station)
	#station_ui_layer.enter_build.connect(start_building)
	#station_ui_layer.jump_to_new_level.connect(generate_level)
	#ship_building_layer.build_complete.connect(exit_building)
	#level_gen_component.level_generated.connect(player.new_level)
	level_gen_component.generate_level()

func start_game() -> void:
	print("Game Start!")
	#start_menu_layer.visible = false
	#intro_guide.visible = true

func generate_level() -> void:
	player.player_ui_layer.visible = true
	#station_ui_layer.visible = false
	#station_ui_layer.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	level_gen_component.generate_level()

#func resume_game() -> void:
	#print("Game resumed!")
	#get_tree().paused = false
	##player.player_ui_layer.visible = true
	##pause_menu_layer.visible = false
#
#func options() -> void:
	#print("Options menu not available yet")
#
#func exit() -> void:
	#get_tree().quit()
#
#func exit_guide() -> void:
	#print("Exited guide!")
	##intro_guide.visible = false
	#start_building()
#
#func start_building() -> void:
	#print("Entering building")
	#player.player_ui_layer.visible = false
	##station_ui_layer.visible = false
	##ship_building_layer.visible = true
	#get_tree().paused = true
	##ship_building_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	##ship_building_layer.start_build()
#
#func exit_building() -> void:
	#print("Exited building")
	#player.player_ui_layer.visible = true
	#ship_building_layer.visible = false
	#ship_building_layer.process_mode = Node.PROCESS_MODE_DISABLED
#
#func enter_station() -> void:
	#player.player_ui_layer.visible = false
	#station_ui_layer.visible = true
	#station_ui_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	#get_tree().paused = true
	#station_ui_layer.enter_station()
#
#func exit_station() -> void:
	#player.player_ui_layer.visible = true
	#station_ui_layer.visible = false
	#station_ui_layer.process_mode = Node.PROCESS_MODE_DISABLED
	#get_tree().paused = false
#
#func can_enter_station() -> bool:
	#if true in [ship_building_layer.visible,station_ui_layer.visible,intro_guide.visible,start_menu_layer.visible]:
		#return false
	#else:
		#return true
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("esc") and not start_menu_layer.visible:
		#player.player_ui_layer.visible = false
		#pause_menu_layer.visible = true
		#get_tree().paused = true
	##if event.is_action_pressed("e") and can_enter_station():
		##enter_station()
