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
	if not player_ui.warp.is_connected(warp):
		player_ui.warp.connect(warp)
	player_ui.init_ui()

func exit() -> void:
	player_ui.process_mode = Node.PROCESS_MODE_DISABLED
	player_ui.visible = false

func death() -> void:
	state_machine.transition(DeathUIState.state_name)

func warp() -> void:
	state_machine.transition(MapUIState.state_name)

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		state_machine.transition(PauseUIState.state_name)
