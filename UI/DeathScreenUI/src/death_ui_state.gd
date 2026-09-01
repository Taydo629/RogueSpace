class_name DeathUIState extends UIState

static var state_name = "DeathUIState"
var death_ui: DeathMenu

func get_state_name() -> String:
	return state_name

func enter() -> void:
	state_machine.get_tree().paused = true
	death_ui = canvas_layer.death_ui
	death_ui.visible = true
	death_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	death_ui.restart.connect(start_game)

func exit() -> void:
	death_ui.visible = false
	death_ui.process_mode = Node.PROCESS_MODE_DISABLED

func start_game() -> void:
	state_machine.transition(StartUIState.state_name)
