extends Node2D

@onready var start_menu_layer: CanvasLayer = $StartMenuLayer
@onready var pause_menu_layer: CanvasLayer = $PauseMenuLayer
@onready var ship_building_layer: CanvasLayer = $ShipBuildingLayer
@onready var level_gen_component: LevelGenComponent = $LevelGenComponent
@onready var menu_component: MenuComponent = $MenuComponent
@onready var intro_guide: Control = $IntroGuide
@onready var player: Player = $Player

func _ready() -> void:
	start_menu_layer.start.connect(start_game)
	start_menu_layer.option.connect(options)
	start_menu_layer.exit.connect(exit)
	pause_menu_layer.resume.connect(resume_game)
	pause_menu_layer.option.connect(options)
	pause_menu_layer.exit.connect(exit)
	intro_guide.guide_end.connect(exit_guide)
	ship_building_layer.build_complete.connect(exit_building)
	
func start_game() -> void:
	print("Game Start!")
	start_menu_layer.visible = false
	intro_guide.visible = true
	
func resume_game() -> void:
	print("Game resumed!")
	get_tree().paused = false
	pause_menu_layer.visible = false

func options() -> void:
	print("Options menu not available yet")

func exit() -> void:
	get_tree().quit()

func exit_guide() -> void:
	print("Exited guide!")
	intro_guide.visible = false
	start_building()

func start_building() -> void:
	print("Entering building")
	ship_building_layer.visible = true
	get_tree().paused = true
	ship_building_layer.start_build()

func exit_building() -> void:
	print("Exited building")
	ship_building_layer.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and not start_menu_layer.visible:
		pause_menu_layer.visible = true
		get_tree().paused = true
