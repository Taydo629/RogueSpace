class_name GuideUIState extends UIState

static var state_name = "GuideUIState"
var guide_ui: GuideUI

func get_state_name() -> String:
	return state_name

func enter() -> void:
	state_machine.get_tree().paused = true
	guide_ui = canvas_layer.guide_ui
	guide_ui.init_ui()
	guide_ui.visible = true
	guide_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	guide_ui.guide_end.connect(guide_end)

func exit() -> void:
	guide_ui.visible = false
	guide_ui.process_mode = Node.PROCESS_MODE_DISABLED

func guide_end() -> void:
	state_machine.transition(state_machine.previous_state.get_state_name())
