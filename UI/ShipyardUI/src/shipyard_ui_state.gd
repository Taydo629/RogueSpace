class_name ShipyardUIState extends UIState

static var state_name = "ShipyardUIState"
var shipyard_ui: ShipyardUI

func get_state_name() -> String:
	return state_name

func enter() -> void:
	print("entering shipyard")
	state_machine.get_tree().paused = true
	shipyard_ui = canvas_layer.shipyard_ui
	shipyard_ui.player = canvas_layer.player
	shipyard_ui.visible = true
	shipyard_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	if state_machine.previous_state.get_state_name() != PauseUIState.state_name:
		shipyard_ui.init_ui()
		shipyard_ui.start_build()
	if not shipyard_ui.build_complete.is_connected(build_complete):
		shipyard_ui.build_complete.connect(build_complete)

func exit() -> void:
	shipyard_ui.visible = false
	shipyard_ui.process_mode = Node.PROCESS_MODE_DISABLED

func build_complete() -> void:
	state_machine.transition(MapUIState.state_name)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("esc"):
		#state_machine.transition(PauseUIState.state_name)
