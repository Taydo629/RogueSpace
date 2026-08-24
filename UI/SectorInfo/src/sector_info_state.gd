class_name SectorInfoUIState extends UIState

static var state_name = "SectorInfoUIState"
var sector_info_ui: SectorInfoUI

func get_state_name() -> String:
	return state_name

func _init(ui_layer: CanvasLayer) -> void:
	canvas_layer = ui_layer
	state_machine = canvas_layer.ui_state_machine

func enter() -> void:
	state_machine.get_tree().paused = true
	sector_info_ui = canvas_layer.sector_info
	sector_info_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	sector_info_ui.visible = true
	sector_info_ui.enter_sector.connect(switch_to_player)

func exit() -> void:
	sector_info_ui.process_mode = Node.PROCESS_MODE_DISABLED
	sector_info_ui.visible = false

func switch_to_player() -> void:
	state_machine.transition(PlayerUIState.state_name)
