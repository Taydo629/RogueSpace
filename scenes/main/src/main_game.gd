extends Node2D

@onready var level_gen_component: LevelGenComponent = $LevelGenComponent
#@onready var player: Player = $LevelGenComponent/Player
#@onready var ui_state_machine: StateMachine = $UIStateMachine
@onready var main_ui_layer: MainUILayer = $MainUILayer

func _ready() -> void:
	# Initialise all of the UI
	main_ui_layer.init_ui()
	# Connect signal for going to next level
	main_ui_layer.travel_to_new_quadrant.connect(travel_to_new_quadrant)
	# Connect signal for restarting game
	main_ui_layer.restart.connect(restart_game)
	# Give level_gen_component reference to MapUI
	level_gen_component.map_ui = main_ui_layer.map_ui
	# Generate the level on start
	level_gen_component.init_game()
	# Give UI reference to level_gen_component to get info about POIs and level number
	main_ui_layer.level_gen = level_gen_component
	# Give UI reference to player for player specific UI
	main_ui_layer.player = level_gen_component.player

	#level_gen_component.generate_level()

func travel_to_new_quadrant(quadrant: Quadrant) -> void:
	level_gen_component.generate_level(quadrant)

func restart_game() -> void:
	level_gen_component.init_game()
	# Give UI reference to level_gen_component to get info about POIs and level number
	main_ui_layer.level_gen = level_gen_component
	# Give UI reference to player for player specific UI
	main_ui_layer.player = level_gen_component.player
	
	#level_gen_component.generate_level(null)
