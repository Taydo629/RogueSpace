class_name PlayerUIState extends UIState

static var state_name = "PlayerUIState"
var player_ui: PlayerUI

func get_state_name() -> String:
	return state_name

func _init(ui_layer: CanvasLayer) -> void:
	canvas_layer = ui_layer
	state_machine = canvas_layer.ui_state_machine

func enter() -> void:
	state_machine.get_tree().paused = false
	player_ui = canvas_layer.player_ui
	if not player_ui.player_died.is_connected(death):
		player_ui.player_died.connect(death)
	player_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	player_ui.visible = true
	if not player_ui.enter_station.is_connected(enter_station):
		player_ui.enter_station.connect(enter_station)
	player_ui.init_ui()

func exit() -> void:
	player_ui.process_mode = Node.PROCESS_MODE_DISABLED
	player_ui.visible = false

func death() -> void:
	state_machine.transition(DeathUIState.state_name)

func enter_station() -> void:
	state_machine.transition(StationUIState.state_name)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
