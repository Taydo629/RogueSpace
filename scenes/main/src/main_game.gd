extends Node2D

@onready var level_gen_component: LevelGenComponent = $LevelGenComponent
@onready var player: Player = $LevelGenComponent/Player
#@onready var ui_state_machine: StateMachine = $UIStateMachine
@onready var main_ui_layer: MainUILayer = $MainUILayer

func _ready() -> void:
	# Give UI reference to player for player specific UI
	main_ui_layer.player = player
	# Give UI reference to level_gen_component to get info about POIs and level number
	main_ui_layer.level_gen = level_gen_component
	# Initialise all of the UI
	main_ui_layer.init_ui()
	# Connect signal for going to next level
	main_ui_layer.generate_level.connect(generate_level)
	# Generate the level on start
	level_gen_component.generate_level()

func generate_level() -> void:
	level_gen_component.generate_level()
