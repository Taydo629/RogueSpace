class_name UIState extends State

var state_machine: StateMachine
var canvas_layer: MainUILayer
var player: Player

var pausable_state: bool = false

func _init(ui_layer: CanvasLayer) -> void:
	canvas_layer = ui_layer
	state_machine = canvas_layer.ui_state_machine

func is_pausable() -> bool:
	return pausable_state
