extends Node2D

@onready var start_menu_layer: CanvasLayer = $StartMenuLayer
@onready var pause_menu_layer: CanvasLayer = $PauseMenuLayer
@onready var level_gen_component: LevelGenComponent = $LevelGenComponent
@onready var menu_component: MenuComponent = $MenuComponent

func _ready() -> void:
	start_menu_layer.start.connect(start_game)
	start_menu_layer.option.connect(options)
	start_menu_layer.exit.connect(exit)
	pause_menu_layer.resume.connect(resume_game)
	pause_menu_layer.option.connect(options)
	pause_menu_layer.exit.connect(exit)
	
func start_game() -> void:
	print("Game Start!")
	start_menu_layer.visible = false

func resume_game() -> void:
	print("Game resumed!")
	get_tree().paused = false
	pause_menu_layer.visible = false

func options() -> void:
	print("Options menu not available yet")

func exit() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and not start_menu_layer.visible:
		pause_menu_layer.visible = true
		get_tree().paused = true
