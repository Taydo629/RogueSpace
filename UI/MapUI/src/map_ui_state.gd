class_name MapUIState extends UIState

static var state_name = "MapUIState"
var map_ui: MapUI

func get_state_name() -> String:
	return state_name

func enter() -> void:
	state_machine.get_tree().paused = true
	map_ui = canvas_layer.map_ui
	if not canvas_layer.level_gen.level_ready.is_connected(load_into_new_quadrant):
		canvas_layer.level_gen.level_ready.connect(load_into_new_quadrant)
	map_ui.visible = true
	map_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	if state_machine.previous_state.get_state_name() != PauseUIState.state_name:
		map_ui.init_map_ui()
	if not map_ui.travel_to_quadrant.is_connected(travel_to_next_quadrant):
		map_ui.travel_to_quadrant.connect(travel_to_next_quadrant)

func exit() -> void:
	map_ui.visible = false
	map_ui.process_mode = Node.PROCESS_MODE_DISABLED

func travel_to_next_quadrant(quadrant: Quadrant) -> void:
	canvas_layer.travel_to_next_quadrant(quadrant)

func load_into_new_quadrant(quadrant: Quadrant) -> void:
	# If statements to load into different UIStates
	if quadrant.type in [Quadrant.TYPE.COMBAT, Quadrant.TYPE.BOSS]:
		state_machine.transition(PlayerUIState.state_name)
	elif quadrant.type == Quadrant.TYPE.NEUTRAL:
		state_machine.transition(DialogUIState.state_name)
	elif quadrant.type == Quadrant.TYPE.SHIPYARD:
		state_machine.transition(BuildUIState.state_name)
	elif quadrant.type == Quadrant.TYPE.MERCAHNT:
		state_machine.transition(StationUIState.state_name)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
