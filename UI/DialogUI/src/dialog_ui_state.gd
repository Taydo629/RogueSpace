class_name DialogUIState extends UIState

static var state_name = "DialogUIState"
var dialog_ui: DialogUI

func get_state_name() -> String:
	return state_name

func enter() -> void:
	state_machine.get_tree().paused = true
	dialog_ui = canvas_layer.dialog_ui
	dialog_ui.visible = true
	dialog_ui.player = canvas_layer.player
	dialog_ui.level_gen = canvas_layer.level_gen
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	if state_machine.previous_state.get_state_name() != PauseUIState.state_name:
		dialog_ui.init_dialog_ui()
	if not dialog_ui.interaction_end.is_connected(interaction_end):
		dialog_ui.interaction_end.connect(interaction_end)

func exit() -> void:
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED

func interaction_end(finished: bool) -> void:
	if finished:
		state_machine.transition(MapUIState.state_name)
	else:
		state_machine.transition(PlayerUIState.state_name)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
