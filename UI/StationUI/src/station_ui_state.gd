class_name StationUIState extends UIState

static var state_name = "StationUIState"
var station_ui: StationUI
var return_state_name: String

func get_state_name() -> String:
	return state_name

func enter() -> void:
	if state_machine.previous_state.get_state_name() != PauseUIState.state_name:
		return_state_name = state_machine.previous_state.get_state_name()
	state_machine.get_tree().paused = true
	station_ui = canvas_layer.station_ui
	station_ui.visible = true
	station_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	if not station_ui.exit_station.is_connected(return_to_game):
		station_ui.exit_station.connect(return_to_game)
	if not station_ui.enter_build.is_connected(enter_build):
		station_ui.enter_build.connect(enter_build)
	if not station_ui.jump_to_new_level.is_connected(travel_to_next_quadrant):
		station_ui.jump_to_new_level.connect(travel_to_next_quadrant)
	station_ui.init_ui()
	#if state_machine.previous_state.get_state_name() != StationUIState.state_name:
		#print("hey")
		#station_ui.init_ui()
		#station_ui.start_build()
	#station_ui.build_complete.connect(build_complete)

func exit() -> void:
	station_ui.visible = false
	station_ui.process_mode = Node.PROCESS_MODE_DISABLED

#func build_complete() -> void:
	#state_machine.transition(PlayerUIState.state_name)

func return_to_game() -> void:
	if return_state_name != null:
		state_machine.transition(return_state_name)
	else:
		state_machine.transition(state_machine.previous_state.get_state_name())

func enter_build() -> void:
	state_machine.transition(BuildUIState.state_name)

func travel_to_next_quadrant() -> void:
	state_machine.transition(MapUIState.state_name)
	#canvas_layer.jump_to_next_sector()

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
