class_name MerchantUIState extends UIState

static var state_name = "StationUIState"
var merchant_ui: MerchantUI
var return_state_name: String

func get_state_name() -> String:
	return state_name

func enter() -> void:
	if state_machine.previous_state.get_state_name() != PauseUIState.state_name:
		return_state_name = state_machine.previous_state.get_state_name()
	state_machine.get_tree().paused = true
	merchant_ui = canvas_layer.merchant_ui
	merchant_ui.visible = true
	merchant_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	#if not merchant_ui.exit_station.is_connected(return_to_game):
		#merchant_ui.exit_station.connect(return_to_game)
	#if not merchant_ui.enter_build.is_connected(enter_build):
		#merchant_ui.enter_build.connect(enter_build)
	if not merchant_ui.warp.is_connected(go_to_map_ui):
		merchant_ui.warp.connect(go_to_map_ui)
	merchant_ui.init_ui()
	#if state_machine.previous_state.get_state_name() != StationUIState.state_name:
		#print("hey")
		#station_ui.init_ui()
		#station_ui.start_build()
	#station_ui.build_complete.connect(build_complete)

func exit() -> void:
	merchant_ui.visible = false
	merchant_ui.process_mode = Node.PROCESS_MODE_DISABLED

#func build_complete() -> void:
	#state_machine.transition(PlayerUIState.state_name)

#func return_to_game() -> void:
	#if return_state_name != null:
		#state_machine.transition(return_state_name)
	#else:
		#state_machine.transition(state_machine.previous_state.get_state_name())

#func enter_build() -> void:
	#state_machine.transition(BuildUIState.state_name)

func go_to_map_ui() -> void:
	state_machine.transition(MapUIState.state_name)
	#canvas_layer.jump_to_next_sector()

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
