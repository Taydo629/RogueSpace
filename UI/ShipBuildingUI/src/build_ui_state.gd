class_name BuildUIState extends UIState

static var state_name = "BuildUIState"
var build_menu_ui: BuildUI

func get_state_name() -> String:
	return state_name

func enter() -> void:
	state_machine.get_tree().paused = true
	build_menu_ui = canvas_layer.ship_building_ui
	build_menu_ui.player = canvas_layer.player
	build_menu_ui.visible = true
	build_menu_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	if state_machine.previous_state.get_state_name() != PauseUIState.state_name:
		build_menu_ui.init_ui()
		build_menu_ui.start_build()
	if not build_menu_ui.build_complete.is_connected(build_complete):
		build_menu_ui.build_complete.connect(build_complete)

func exit() -> void:
	build_menu_ui.visible = false
	build_menu_ui.process_mode = Node.PROCESS_MODE_DISABLED

func build_complete() -> void:
	state_machine.transition(PlayerUIState.state_name)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("esc"):
		#state_machine.transition(PauseUIState.state_name)
