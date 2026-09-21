class_name MapUIState extends UIState

static var state_name = "MapUIState"
var map_ui: MapUI

func get_state_name() -> String:
	return state_name

func enter() -> void:
	state_machine.get_tree().paused = true
	map_ui = canvas_layer.map_ui
	map_ui.visible = true
	map_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	if state_machine.previous_state.get_state_name() != PauseUIState.state_name:
		map_ui.init_map_ui()
	if not map_ui.travel_to_quadrant.is_connected(travel):
		map_ui.travel_to_quadrant.connect(travel)
func exit() -> void:
	map_ui.visible = false
	map_ui.process_mode = Node.PROCESS_MODE_DISABLED

func travel(quadrant: Quadrant) -> void:
	state_machine.transition(SectorInfoUIState.state_name)
	canvas_layer.travel_to_next_quadrant(quadrant)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
