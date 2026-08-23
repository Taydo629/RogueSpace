class_name PauseUIState extends UIState

static var state_name = "PauseUIState"
var pause_menu_ui: PauseMenu
var return_state_name: String

func get_state_name() -> String:
	return state_name

func enter() -> void:
	if state_machine.previous_state.get_state_name() != GuideUIState.state_name:
		return_state_name = state_machine.previous_state.get_state_name()
	state_machine.get_tree().paused = true
	pause_menu_ui = canvas_layer.pause_menu_ui
	pause_menu_ui.visible = true
	pause_menu_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu_ui.resume.connect(resume)
	pause_menu_ui.guide.connect(guide)

func exit() -> void:
	pause_menu_ui.visible = false
	pause_menu_ui.process_mode = Node.PROCESS_MODE_DISABLED

func resume() -> void:
	if return_state_name != null:
		state_machine.transition(return_state_name)
	else:
		state_machine.transition(state_machine.previous_state.get_state_name())

func guide() -> void:
	state_machine.transition(GuideUIState.state_name)
